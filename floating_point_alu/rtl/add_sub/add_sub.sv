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
// 64-Bit Floating Point Addition and Subtraction Module
// Based on IEEE-754 Representation
// Sign     --------->> [63]    1 Bit
// Exponent --------->> [62:52] 11 Bits
// Mantissa --------->> [51:0]  52 Bits
module add_sub #(parameter OUTPUT_REG = 1)(
  input  logic        Clock       ,    // Clock signal
  input  logic [63:0] operand_a, operand_b, // 64-bit IEEE-754 inputs for addition or subtraction
  input  logic [ 2:0] fpalu_mode  ,    // Mode: 000 for Addition, 001 for Subtraction
  output logic        exception   ,    // Output flag for detecting exceptions (NaN, Infinity)
  output logic [63:0] result_add_sub  // 64-bit IEEE-754 result of addition/subtraction
);

  //-------------------------------------
  // Internal signals declaration
  //-------------------------------------

  logic        operation_add_sub;  // Signal for deciding addition or subtraction
  logic        enable           ;  // Enable signal to control the operation
  logic        Sign             ;  // Sign of the final result
  logic [63:0] OperandA, OperandB; // Adjusted operands after checking which is larger
  logic [52:0] Mantissa_A, Mantissa_B; // Mantissa (fractional part) of operand A and B
  logic [10:0] diff             ;  // Difference between exponents of operand A and operand B

  logic [52:0] Mantissa_B_add_sub; // Mantissa part of operand B for either addition or subtraction
  logic [10:0] Exp_B_add_sub     ; // Adjusted exponent of operand B for either addition or subtraction

  logic [53:0] Mantissa_add     ;  // Mantissa of the result for addition
  logic [62:0] Summation        ;  // Final result {Exponent + Mantissa} after addition

  logic [52:0] Mantissa_sub_Inverted; // Inverted mantissa of operand B for subtraction
  logic [53:0] Mantissa_sub     ;  // Mantissa of the result for subtraction
  logic [62:0] sub_diff         ;  // Final result {Exponent + Mantissa} after subtraction
  logic [53:0] Difference       ;  // Difference of mantissas after subtraction
  logic [10:0] SubExponent      ;  // Final exponent after subtraction
  logic        Compare          ;  // To compare exponents of operand A and operand B

  //----------------------------------------------
  // Determine which operand is larger and swap them accordingly
  // If operand_a > operand_b => enable = 0, operand A is larger
  // If operand_a < operand_b => enable = 1, operand B is larger
  assign {enable, OperandA, OperandB} = 
      (operand_a[62:0] < operand_b[62:0]) ? 
      {1'b1, operand_b, operand_a} : {1'b0, operand_a, operand_b};

  always_comb begin
    // Set the exception flag if either operand's exponent is all 1s, indicating Infinity or NaN
    exception = (&OperandA[62:52]) | (&OperandB[62:52]);

    // Determine the sign of the result based on the operation (addition or subtraction)
    // For subtraction, sign depends on which operand is larger
    Sign = (fpalu_mode == 3'b001) ? (enable ? !OperandA[63] : OperandA[63]) : OperandA[63];

    // Extract the mantissa and determine if implicit leading 1 is present
    // If the exponent is not zero, implicit leading 1 is assumed, otherwise 0
    operation_add_sub = (fpalu_mode == 3'b001) ? (OperandA[63] ^ OperandB[63]) : 
                                                ~(OperandA[63] ^ OperandB[63]);
    Mantissa_A = (|OperandA[62:52]) ? {1'b1, OperandA[51:0]} : {1'b0, OperandA[51:0]};
    Mantissa_B = (|OperandB[62:52]) ? {1'b1, OperandB[51:0]} : {1'b0, OperandB[51:0]};
  end

  always_comb begin
    // Compute the difference between the exponents of the two operands
    diff = OperandA[62:52] - OperandB[62:52];

    // Shift the mantissa of operand B by the difference in exponents (aligning the mantissas)
    Mantissa_B_add_sub = Mantissa_B >> diff;

    // Adjust the exponent of operand B by adding the difference
    Exp_B_add_sub = OperandB[62:52] + diff;

    // Check if the exponents are equal
    Compare = (OperandA[62:52] == Exp_B_add_sub);
  end

  // Addition logic begins
  always_comb begin
    // Perform the addition if exponents are equal and signs are the same
    Mantissa_add = (Compare & operation_add_sub) ? (Mantissa_A + Mantissa_B_add_sub) : 54'd0;

    // If there is a carry, use the most significant 53 bits of the mantissa, else use the least significant 52 bits
    Summation[51:0] = Mantissa_add[53] ? Mantissa_add[52:1] : Mantissa_add[51:0];

    // If a carry was generated, increment the exponent by 1
    Summation[62:52] = Mantissa_add[53] ? (1'b1 + OperandA[62:52]) : OperandA[62:52];
  end

  // Subtraction logic begins
  // Normalize the mantissa of the result for subtraction
  Shifter Shift_Right (Mantissa_sub, OperandA[62:52], Difference, SubExponent);

  always_comb begin
    // Invert the mantissa of operand B for subtraction, and add 1 (two's complement)
    Mantissa_sub_Inverted = (Compare & !operation_add_sub) ? ~(Mantissa_B_add_sub) + 53'd1 : 53'd0;

    // Subtract the mantissas
    Mantissa_sub = Compare ? (Mantissa_A + Mantissa_sub_Inverted) : 54'd0;

    // Store the final exponent after subtraction
    sub_diff[62:52] = SubExponent;

    // Store the final mantissa after subtraction
    sub_diff[51:0] = Difference[51:0];
  end

  // Assign the final result
  // If an exception occurs, the result will be set to zero
  // The final result is determined based on the operation (addition or subtraction)
  generate
    if (OUTPUT_REG) begin
      always_ff @(posedge Clock) begin
        result_add_sub <= exception ? 64'b0 : ((!operation_add_sub) ? {Sign, sub_diff} : {Sign, Summation});
      end
    end
    else begin 
      always_comb begin
        result_add_sub <= exception ? 64'b0 : ((!operation_add_sub) ? {Sign, sub_diff} : {Sign, Summation});
      end
    end
  endgenerate

endmodule : add_sub
