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
// Base case: 16-bit carry-less multiplier (explicit implementation)
module cl_multiplier_16 (
  input  logic [15:0] A,
  input  logic [15:0] B,
  output logic [31:0] P
);

  //------------------
  // local parameters
  //------------------

  //------------------
  // internal wires & registers
  //------------------

  //------------------
  // implementation
  //------------------

  // Polynomial multiplication (carry-less)
  always_comb begin
    P = 32'b0;
    for (int i = 0; i < 16; i++) begin
      for (int j = 0; j < 16; j++) begin
        P[i+j] = P[i+j] ^ (A[i] & B[j]);
      end
    end
  end

endmodule : cl_multiplier_16
