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

// Algorithm 1 Multiplication in GF (2128 ). Computes the value of Z = X · Y , where X, Y and
// Z ∈ GF (2128 ). from gcm-spec.pfd page 3
//----------------------------------------------------------------------------------------------
// Z ← 0, V ← X
// for i = 0 to 127 do
// if Yi = 1 then
// Z ←Z ⊕V
// end if
// if V127 = 0 then
// V ← rightshift(V )
// else
// V ← rightshift(V ) ⊕ R
// end if
// end for
// return Z
//----------------------------------------------------------------------------------------------
// argument one bit to the right. More formally, whenever W = rightshift(V ), then Wi = Vi−1 for
// 1 ≤ i ≤ 127 and W0 = 0.

module gf128_multiplier (
  input  logic [128-1:0] x, // First operand
  input  logic [128-1:0] y, // Second operand
  output logic [128-1:0] z  // Result of multiplication
);
  //-------------------------------------
  // local parameters
  //-------------------------------------

  //-------------------------------------
  // Internal wire and regs
  //-------------------------------------
  logic [ 127:0] temp_x     ;
  logic [ 127:0] temp_z     ;
  logic [ 127:0] next_x     ;
  logic [ 127:0] next_z     ;



  //-------------------------------------
  // Implementation
  //-------------------------------------

    always_comb begin
      temp_x = x;
      temp_z = 128'b0;
      for (int i = 127; i >= 0; i--) begin
        if (y[i]) begin
          next_z = temp_z ^ temp_x;
        end 
        else begin
          next_z = temp_z;
        end
        if (temp_x[0]) begin
          next_x           = (temp_x >> 1 );
          next_x[127:120]  = next_x[127:120] ^ 8'b1110_0001;
        end 
        else begin
          next_x = (temp_x >> 1);
        end
        temp_x = next_x;
        temp_z = next_z;
      end
    end

   assign z = temp_z;


endmodule : gf128_multiplier