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

//All Inputs and Outputs are in the format of IEEE-754 Representation.
module floating_point_alu (
  input  logic          Clock         ,
  input  logic [ 3-1:0] fpalu_mode    ,
  input  logic [64-1:0] operand_a     ,
  input  logic [64-1:0] operand_b     ,
  output logic [64-1:0] result_add_sub,
  output logic [64-1:0] result_mul    ,
  output logic [64-1:0] result_div
);

  //-----------------
  // internal signals
  //-----------------
  logic exception_add_sub;
  logic exception_mul    ;
  logic overflow         ;
  logic underflow        ;
  logic exception_div    ;

  //-------------------
  // implemenattion
  //-------------------

  //Addition and Subtraction Block
  //fpalu_mode ---> 000 ---> Addition
  //fpalu_mode ---> 001 ---> Subtraction
  add_sub u_add_sub (
    .Clock         (Clock            ),
    .operand_a     (operand_a        ),
    .operand_b     (operand_b        ),
    .fpalu_mode    (fpalu_mode       ),
    .exception     (exception_add_sub),
    .result_add_sub(result_add_sub   )
  );

  //Multiplication Block
  //fpalu_mode ---> 010 ---> Multiplication

  multiplication u_multiplication (
    .Clock     (Clock        ), // Clock signal for synchronization
    .fpalu_mode(fpalu_mode   ), // Operation mode: 010 for multiplication
    .operand_a (operand_a    ), // 64-bit IEEE-754 operand A
    .operand_b (operand_b    ), // 64-bit IEEE-754 operand B
    .exception (exception_mul), // Exception flag for NaN or Infinity
    .overflow  (overflow     ), // Overflow flag for exponent overflow
    .underflow (underflow    ), // Underflow flag for exponent underflow
    .result_mul(result_mul   )  // 64-bit IEEE-754 result of multiplication
  );

  //Division Block
  //fpalu_mode ---> 011 ---> Division

  division u_division (
    .Clock     (Clock        ), // Clock signal for synchronization
    .operand_a (operand_a    ), // 64-bit IEEE-754 operand A (Dividend)
    .operand_b (operand_b    ), // 64-bit IEEE-754 operand B (Divisor)
    .fpalu_mode(fpalu_mode   ), // Floating-point ALU mode (011 for division)
    .exception (exception_div), // Exception flag for NaN or Infinity
    .result_div(result_div   )  // 64-bit IEEE-754 result of division
  );




endmodule : floating_point_alu
