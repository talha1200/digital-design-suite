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

module equation0 (
  input  logic r ,
  input  logic Qo,
  input  logic y ,
  input  logic u ,
  output logic Q ,
  output logic d
);
  
  //----------
  // internel signals
  //----------
  logic rNot, yNot, QoNot, uNot;

  //-----------
  // implementation
  //-----------

  always_comb begin 
    rNot  = ~r;
    yNot  = ~y;
    QoNot = ~Qo;
    uNot  = ~u;
  end
  
  always_comb begin 
    Q = (rNot & (y | Qo)) | (y & Qo);
    d = ((rNot & uNot) & (y ^ Qo)) | (r & (u | ~(y ^ Qo)));
  end

endmodule : equation0
