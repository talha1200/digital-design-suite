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
import gf_128_pkg::*;

module koa_gf128_multiplier (
  input  logic [127:0] A,
  input  logic [127:0] B,
  output logic [127:0] P
);

  //-----------------
  // local parameters
  //-----------------

  //----------------
  // internal wires & registers
  //----------------
  logic [ 63:0] A_high, A_low, B_high, B_low;
  logic [ 63:0] AhXorAl       ;
  logic [ 63:0] BhXorBl       ;
  logic [127:0] A_rev         ;
  logic [127:0] B_rev         ;
  logic [127:0] Z0, Z1, Z2;
  logic [255:0] full_product  ;
  logic [127:0] reduce_product;


  //----------------
  // implementation
  //----------------

  //-------------------------------------------------------------------------
  // Main combinational process.
  // 1. Reverse input bits to convert from MSB-first to LSB-first.
  // 2. Multiply the polynomial using KOA multiplier.
  // 3. Reduce the result using the irreducible polynomial.
  // 3. Reverse the result back.
  //-------------------------------------------------------------------------

  assign A_rev = reverse_128(A);
  assign B_rev = reverse_128(B);


  // Split 128-bit inputs into 64-bit halves for KOA
  assign A_high = A_rev[127:64];
  assign A_low  = A_rev[63:0];
  assign B_high = B_rev[127:64];
  assign B_low  = B_rev[63:0];

  // Compute KOA sub-products using carry-less multipliers
  cl_multiplier_64 u0_cl_multiplier_64 (
    .A(A_low),
    .B(B_low),
    .P(Z0   )
  );
  cl_multiplier_64 u1_cl_multiplier_64 (
    .A(A_high),
    .B(B_high),
    .P(Z2    )
  );

  assign AhXorAl = A_high ^ A_low;
  assign BhXorBl = B_high ^ B_low;

  cl_multiplier_64 u_2cl_multiplier_64 (
    .A(AhXorAl),
    .B(BhXorBl),
    .P(Z1     )
  );

  // Combine results into 256-bit product
  assign full_product = (Z2 << 128) ^ ((Z1 ^ Z0 ^ Z2) << 64) ^ Z0;

  // Reduce 256-bit product modulo P(x) = x^128 + x^7 + x^2 + x + 1
  assign reduce_product = gf_reduce(full_product);

  // Reverse the result back to MSB-first
  assign P = reverse_128(reduce_product);

endmodule : koa_gf128_multiplier