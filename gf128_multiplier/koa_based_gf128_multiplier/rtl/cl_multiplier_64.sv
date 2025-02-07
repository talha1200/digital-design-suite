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
// Carry-less 64-bit multiplier (KOA split into 32-bit halves)
module cl_multiplier_64 (
  input  logic [ 63:0] A,
  input  logic [ 63:0] B,
  output logic [127:0] P
);

  //------------------
  // local parameters
  //------------------

  //------------------
  // internal wires & registers
  //------------------
  logic [31:0] A_high, A_low, B_high, B_low;
  logic [31:0] AhXorAl;
  logic [31:0] BhXorBl;
  logic [63:0] Z0, Z1, Z2;

  //------------------
  // implementation
  //------------------

  // Split into 32-bit halves for KOA recursion
  assign A_high = A[63:32];
  assign A_low  = A[31:0];
  assign B_high = B[63:32];
  assign B_low  = B[31:0];

  cl_multiplier_32 u0_cl_multiplier_32 (
    .A(A_low),
    .B(B_low),
    .P(Z0   )
  );
  cl_multiplier_32 u1_cl_multiplier_32 (
    .A(A_high),
    .B(B_high),
    .P(Z2    )
  );

  assign AhXorAl = A_high ^ A_low;
  assign BhXorBl = B_high ^ B_low;

  cl_multiplier_32 u2_cl_multiplier_32 (
    .A(AhXorAl),
    .B(BhXorBl),
    .P(Z1     )
  );

  // Combine 32-bit sub-products into 64-bit result
  assign P = (Z2 << 64) ^ ((Z1 ^ Z0 ^ Z2) << 32) ^ Z0;

endmodule : cl_multiplier_64
