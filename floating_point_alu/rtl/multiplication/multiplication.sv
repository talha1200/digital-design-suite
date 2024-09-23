`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024 Talha Mahboob
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
///////////////////////////////////////////////////////////////////////////////
// 64-Bit Floating Point Multiplication Module
// Based on IEEE-754 Representation
// Sign     --------->> [63]    1 Bit
// Exponent --------->> [62:52] 11 Bits
// Mantissa --------->> [51:0]  52 Bits
module multiplication (
  input  logic          Clock     ,    // Clock signal for synchronization
  input  logic [   2:0] fpalu_mode,    // Operation mode: 010 for multiplication
  input  logic [64-1:0] operand_a ,    // 64-bit IEEE-754 operand A
  input  logic [64-1:0] operand_b ,    // 64-bit IEEE-754 operand B
  output logic          exception ,    // Exception flag for NaN or Infinity
  output logic          overflow  ,    // Overflow flag for exponent overflow
  output logic          underflow ,    // Underflow flag for exponent underflow
  output logic [64-1:0] result_mul     // 64-bit IEEE-754 result of multiplication
);

  //---------------------
  // Internal signals
  //---------------------
  logic         sign, Rounded_product, normalised, zero;  // Signals for result sign, rounding, normalization, and zero detection
  logic [ 11:0] exponent        ;  // Raw Exponent before bias adjustment
  logic [ 11:0] sum_exponent    ;  // Sum of exponents from both operands
  logic [ 51:0] product_mantissa;  // Final mantissa after normalization and rounding
  logic [ 52:0] Mantissa1, Mantissa2;  // 53-bit mantissas (with hidden bit)
  logic [107:0] product, product_normalised; // 108-bit product of mantissas (for precision during multiplication)

  //------------------
  // Implementation
  //------------------

  always_ff @(posedge Clock) begin
    // The sign of the result is the XOR of the signs of both operands
    sign      <= operand_a[63] ^ operand_b[63];

    // Exception flag is set if either operand has an exponent of all 1s (indicating NaN or Infinity)
    exception <= (&operand_a[62:52]) | (&operand_b[62:52]);

    // Assigning significand (mantissa) values based on the hidden/implicit bit
    // If the exponent is non-zero, the hidden bit is 1; otherwise, it is 0
    Mantissa1 <= (|operand_a[62:52]) ? {1'b1, operand_a[51:0]} : {1'b0, operand_a[51:0]};
    Mantissa2 <= (|operand_b[62:52]) ? {1'b1, operand_b[51:0]} : {1'b0, operand_b[51:0]};
  end

  always_ff @(posedge Clock) begin
    // Multiplying the two mantissas to get the product (with more precision due to 107-bit size)
    product <= Mantissa1 * Mantissa2;
  end

  always_ff @(posedge Clock) begin
    // Check for rounding by OR'ing the lower 52 bits of the product
    Rounded_product    <= |product_normalised[51:0];

    // Check if normalization is required (if the product exceeds 53 bits, indicated by the MSB being set)
    normalised         <= product[107] ? 1'b1 : 1'b0;

    // If normalization is required, shift the product right by 1 bit; otherwise, leave it unchanged
    product_normalised <= normalised ? product : product << 1;

    // The final mantissa is the most significant 53 bits of the normalized product, plus rounding
    product_mantissa   <= product_normalised[106:53] + (product_normalised[53] & Rounded_product);

    // Check if the result is zero (if no exception and the mantissa is zero)
    zero               <= exception ? 1'b0 : (product_mantissa == 53'd0) ? 1'b1 : 1'b0;

    // Add the exponents of both operands (without bias correction at this stage)
    sum_exponent       <= operand_a[62:52] + operand_b[62:52];

    // Subtract the bias value (1023) from the sum of the exponents and adjust for normalization
    exponent           <= sum_exponent - 10'd1023 + normalised;

    // Overflow condition: if the exponent exceeds its maximum allowed value (1023)
    // Overflow also occurs if the exponent reaches its maximum value (3072) due to exceptions
    overflow           <= ((exponent[11] & !exponent[10]) & !zero);

    // Underflow condition: if the exponent is too small (less than 1023) after bias correction
    underflow          <= ((exponent[11] & exponent[10]) & !zero) ? 1'b1 : 1'b0;
  end

  // Final result assignment
  always_ff @(posedge Clock) begin
    if(fpalu_mode == 3'b010) begin
      // If an exception occurs, the result is set to zero
      // If the result is zero, only the sign bit is preserved
      // If overflow occurs, the result is set to Infinity (with all exponent bits set to 1)
      // If underflow occurs, the result is set to zero
      // Otherwise, assign the computed sign, exponent, and mantissa to the result
      result_mul = exception ? 64'd0 : 
                   zero      ? {sign, 63'd0} :
                   overflow  ? {sign, 11'hFF, 53'd0} :
                   underflow ? {sign, 63'd0} :
                               {sign, exponent[10:0], product_mantissa};
    end
    else begin
      // If the operation mode is not multiplication, set the result to zero
      result_mul = 64'd0;
    end
  end

endmodule : multiplication

