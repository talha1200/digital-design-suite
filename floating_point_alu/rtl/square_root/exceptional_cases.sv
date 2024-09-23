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

module exceptional_cases #(
  parameter SIZE          = 8'd64,
  parameter EXPONENT_SIZE = 4'd11,
  parameter MANTISSA_SIZE = 6'd52
) (
  input  logic                     SIGN      ,
  input  logic [EXPONENT_SIZE-1:0] EXPONENT  ,
  input  logic [MANTISSA_SIZE-1:0] MANTISSA  ,
  output logic [         SIZE-1:0] out       ,
  output logic                     Normalized
);

  always_comb begin
    // if a is NaN (Not a Number) or negative return NaN
    if (SIGN == 1 || (EXPONENT[10:0] == 2047 && MANTISSA[51:0] != 0)) begin
      out[63]    = SIGN;
      out[62:52] = 2047;
      out[51]    = 1;
      out[50:0]  = 0;
      // state = put_z;
    end
    // if a is inf return inf
    else if (EXPONENT[10:0] == 2047) begin
      out[63]    = SIGN;
      out[62:52] = 2047;
      out[51:0]  = 0;
      // state = put_z;
      // if a is zero return zero
    end
    else if ((($signed(EXPONENT[10:0]) == 0) && (MANTISSA[51:0] == 0))) begin
      out[63]    = SIGN;
      out[62:52] = 0;
      out[51:0]  = 0;
      // state = put_z;
    end
    else begin
      // Denormalised Number
      if (EXPONENT < 2047) begin
        Normalized = 1;
        out        = {SIGN, EXPONENT, MANTISSA};
      end
      else begin
        Normalized = 0;
        out[63]    = SIGN;
        out[62:52] = 2047;
        out[51]    = 1;
        out[50:0]  = 0;
      end
    end
  end
endmodule : exceptional_cases