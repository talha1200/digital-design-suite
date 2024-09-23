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

module tb_fpalu ();

  logic          Clock         ;
  logic [ 2:0]   fpalu_mode    ; // Adjusted bit-width to 3
  logic [63:0]   operand_a     ;
  logic [63:0]   operand_b     ;
  logic [63:0]   result_add_sub;
  logic [63:0]   result_mul    ;
  logic [63:0]   result_div    ;

  // Instantiate the Unit Under Test (UUT)
  floating_point_alu u_floating_point_alu (
    .Clock         (Clock         ),
    .fpalu_mode    (fpalu_mode    ),
    .operand_a     (operand_a     ),
    .operand_b     (operand_b     ),
    .result_add_sub(result_add_sub),
    .result_mul    (result_mul    ),
    .result_div    (result_div    )
  );

  // Clock generation
  always begin
    #50 Clock = ~Clock; // Adjusted clock period for faster simulation
  end

  initial begin
    // Initialize Inputs
    Clock = 0;

    // Test Case 1: Addition
    operand_a = 64'b0100000000110100100000000000000000000000000000000000000000000000; // 20.5
    operand_b = 64'b0100000000010110000000000000000000000000000000000000000000000000; // 5.5
    fpalu_mode = 3'b000; // Addition
    #100;

    // Test Case 2: Subtraction
    operand_a = 64'b0100000001000001000000000000000000000000000000000000000000000000; // 34
    operand_b = 64'b0100000000000001100110011001100110011001100110011001100110011010; // 2.2
    fpalu_mode = 3'b001; // Subtraction
    #100;

    // Test Case 3: Multiplication
    operand_a = 64'b0100000000100011111110101110000101000111101011100001010001111011; // 9.99
    operand_b = 64'b0100000000010110000000000000000000000000000000000000000000000000; // 5.5
    fpalu_mode = 3'b010; // Multiplication
    #100;

    // Test Case 4: Division
    operand_a = 64'b0100000001011001010000000000000000000000000000000000000000000000; // 101
    operand_b = 64'b1100000000100100000000000000000000000000000000000000000000000000; // -10
    fpalu_mode = 3'b011; // Division
    #100;

    // Test Case 5: Square Root
    operand_a = 64'b0100000001010100001000000000000000000000000000000000000000000000; // 80.5
    operand_b = 64'b0000000000000000000000000000000000000000000000000000000000000000; // 0 (only one operand for square root)
    fpalu_mode = 3'b100; // Square Root
    #100;

    // Additional Test Case: Division by Zero
    operand_a = 64'b0100000001010100001000000000000000000000000000000000000000000000; // 80.5
    operand_b = 64'b0000000000000000000000000000000000000000000000000000000000000000; // 0
    fpalu_mode = 3'b011; // Division
    #100;

    // Additional Test Case: Negative Multiplication
    operand_a = 64'b1100000001010100001000000000000000000000000000000000000000000000; // -80.5
    operand_b = 64'b0100000000010110000000000000000000000000000000000000000000000000; // 5.5
    fpalu_mode = 3'b010; // Multiplication
    #100;

    // End of simulation
    $finish;
  end

endmodule : tb_fpalu

