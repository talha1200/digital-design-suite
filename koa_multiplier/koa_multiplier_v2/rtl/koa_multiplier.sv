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

//---------------------------------------------
// Dl  = Al * Bl
// Dhl = (Ah ⊕ Al) * (Bh ⊕ Bl)
// Dh  = Ah * Bh
// D   = Dh X^m ⊕ X^m/2 (Dhl ⊕ Dh ⊕ Dl ) ⊕ Dl
//---------------------------------------------

module koa_multiplier (
  input  logic [127:0] mult_a,
  input  logic [127:0] mult_b,
  output logic [127:0] mult_d
);

  // Intermediate registers for pipelining
  logic [127:0] stage1_a, stage1_b;
  logic [255:0] stage2_p0, stage2_p1, stage2_p2;
  logic [255:0] stage3_result ;

  // Stage 1: Split inputs and prepare for Karatsuba
  always_comb begin
    stage1_a = mult_a;
    stage1_b = mult_b;
  end

  // Stage 2: Perform Karatsuba multiplication
  logic [ 63:0] a0, a1, b0, b1;
  logic [127:0] p0, p1, p2, sum_a, sum_b;
  always_comb begin
    a0 = stage1_a[63:0];
    a1 = stage1_a[127:64];
    b0 = stage1_b[63:0];
    b1 = stage1_b[127:64];

    p0 = a0 * b0;   // Lower part multiplication
    p1 = a1 * b1;   // Upper part multiplication

    sum_a = a0 ^ a1;
    sum_b = b0 ^ b1;
    p2    = sum_a * sum_b;   // Cross terms multiplication

    // Stage 2 intermediate products aligned for combination
    stage2_p0 = {128'b0, p0};                       // Lower part aligned
    stage2_p1 = {p1, 128'b0};                       // Upper part aligned
    stage2_p2 = {64'b0, p2 ^ p0 ^ p1, 64'b0};      // Cross terms aligned
  end

  // Stage 3: Combine results (Karatsuba combination step)
  always_comb begin
    stage3_result = stage2_p0 ^ stage2_p1 ^ stage2_p2;
  end

  assign mult_d = stage3_result;


endmodule : koa_multiplier