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
// 64-Bit Floating Point Division Module
// Based on IEEE-754 Representation
// Sign     --------->> [63]    1  Bit
// Exponent --------->> [62:52] 11 Bits
// Mantissa --------->> [51:0]  52 Bits
module division (
  input  logic          Clock     ,   // Clock signal for synchronization
  input  logic [64-1:0] operand_a ,   // 64-bit IEEE-754 operand A (Dividend)
  input  logic [64-1:0] operand_b ,   // 64-bit IEEE-754 operand B (Divisor)
  input  logic [   2:0] fpalu_mode,   // Floating-point ALU mode (011 for division)
  output logic          exception ,   // Exception flag for NaN or Infinity
  output logic [64-1:0] result_div    // 64-bit IEEE-754 result of division
);

  //----------------
  // Internal signals
  //----------------

  logic          sign            ;   // Sign of the result
  logic [11-1:0] Normilzed_Shift ;   // Normalization shift for the divisor exponent
  logic [11-1:0] exponent_op_a   ;   // Exponent of operand_a adjusted for normalization
  logic [64-1:0] divisor         ;   // Normalized divisor
  logic [64-1:0] input1          ;   // Adjusted version of operand_a (normalized dividend)
  logic [64-1:0] HalfWay_X0      ;   // Intermediate result from the first multiplication stage
  logic [64-1:0] Iteration_X0    ;   // Result of the iterative refinement using add_sub block
  logic [64-1:0] solution        ;   // Final result of the division after refinement

  //--------------
  // Implementation
  //--------------

  // Initial setup and normalization
  always_comb begin
    // Exception flag is set if either operand has an exponent of all 1s (indicating NaN or Infinity)
    exception       = (&operand_a[62:52]) | (&operand_b[62:52]);

    // The sign of the result is determined by the XOR of the signs of both operands
    sign            = operand_a[63] ^ operand_b[63];

    // Compute the normalization shift for the divisor's exponent
    Normilzed_Shift = 10'd1022 - operand_b[62:52];

    // Normalize the divisor by setting its exponent to 1022 (corresponding to 1 in IEEE-754)
    divisor         = {1'b0, 10'd1022, operand_b[51:0]};

    // Adjust the exponent of operand_a by adding the normalization shift
    exponent_op_a   = operand_a[62:52] + Normilzed_Shift;

    // Prepare the normalized version of operand_a (input1) by concatenating its sign, adjusted exponent, and mantissa
    input1          = {operand_a[63], exponent_op_a, operand_a[51:0]};
  end

  // Division algorithm implementation using multiplication and addition-subtraction
  // This approach uses Newton-Raphson iteration to refine the initial guess for the division result

  // Step 1: Multiply the normalized divisor by a pre-calculated constant
  // The constant 64'hC00169695FFFFE00 is obtained through simulation and testing to improve convergence in the next step
  multiplication u0_multiplication (
    .Clock     (Clock               ),
    .fpalu_mode(3'b010              ),   // Mode for multiplication
    .operand_a (64'hC00169695FFFFE00),   // Pre-calculated constant for the initial estimate
    .operand_b (divisor             ),   // Normalized divisor
    .exception (                    ),
    .overflow  (                    ),
    .underflow (                    ),
    .result_mul(HalfWay_X0          )    // Intermediate result
  );

  // Step 2: Refining the intermediate result using addition-subtraction
  // The constant 64'h40069696A0001333 is also pre-calculated through testing
  add_sub #(.OUTPUT_REG(0)) u_add_sub (
    .Clock         (Clock               ),
    .operand_a     (HalfWay_X0          ), // Result from the first multiplication
    .operand_b     (64'h40069696A0001333), // Pre-calculated constant for correction
    .fpalu_mode    (3'b000              ), // Mode for addition
    .exception     (                    ),
    .result_add_sub(Iteration_X0        )  // Refined result after addition-subtraction
  );

  // Step 3: Multiply the refined result by the normalized dividend (input1)
  multiplication u1_multiplication (
    .Clock     (Clock       ),
    .fpalu_mode(3'b010      ),  // Mode for multiplication
    .operand_a (Iteration_X0),  // Refined estimate from the previous step
    .operand_b (input1      ),  // Normalized dividend
    .exception (            ),
    .overflow  (            ),
    .underflow (            ),
    .result_mul(solution    )   // Final solution after the iterative process
  );

  // Step 4: Concatenate the result with the correct sign and output the result
  always_comb begin
    if(fpalu_mode == 3'b011) begin
      // Concatenate the sign with the final solution
      result_div = {sign, solution[62:0]};
    end
    else begin
      // If the operation mode is not division, set the result to zero
      result_div = 64'd0;
    end
  end

endmodule : division

