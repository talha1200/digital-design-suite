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

// Algorithm KOA(X, Y)
// if (Size(X) = 1) then
// Result: OneBitMultiplier (X, Y)
// Else
// SumX := Hiqh(X) + Low(X) ;
// SumY := High(Y) + Low(Y) ;
// KOA 1 : KOA (Hiqh(X), High(Y), Productl);
// KOA 2 : KOA (Low(X), Low(Y), Product2);
// KOA 3 : KOA (SumX, SumY, Product3);
// Rigthshiftadd1 : RightShiftadd (Product1, Size(X)) +
// RightShift (Product3 – Product1 – Product2,
// Size(X)/2) + Product2, Result;
// end algorithm

module KOA_Multiplier_128bit (
  input  logic [127:0] a      ,
  input  logic [127:0] b      ,
  output logic [255:0] product
);

  logic [ 63:0] a_high, a_low, b_high, b_low;
  logic [255:0] z0, z1, z2;
  logic [255:0] a_high_b_high, a_low_b_low, a_sum_b_sum;

  // Split the inputs into high and low parts
  assign a_high = a[127:64];
  assign a_low  = a[63:0];
  assign b_high = b[127:64];
  assign b_low  = b[63:0];

  // Calculate the three products
  assign a_high_b_high = a_high * b_high;
  assign a_low_b_low   = a_low * b_low;
  assign a_sum_b_sum   = (a_high + a_low) * (b_high + b_low);

  // Calculate the intermediate values
  assign z0 = a_low_b_low;
  assign z1 = a_sum_b_sum - a_high_b_high - a_low_b_low;
  assign z2 = a_high_b_high;

  // Combine the results
  assign product = (z2 << 128) + (z1 << 64) + z0;

endmodule