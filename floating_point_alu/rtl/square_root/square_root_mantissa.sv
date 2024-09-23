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

module square_root_mantissa #(
  parameter BINARY_SIZE      = 8'd106,
  parameter HALF_BINARY_SIZE = 8'd53 ,
  parameter MANTISSA_SIZE    = 6'd52
) (
  input  logic [  BINARY_SIZE-1:0] op_a      ,
  output logic [MANTISSA_SIZE-1:0] MANTISSA  ,
  output logic                     DONE_FLAGE
);

  wire [HALF_BINARY_SIZE-1:0] SQUARE_ROOT_OUT       ;
  reg                         SQUARE_ROOT_DONE_FLAGE;


  square_root_binary #(.SIZE(BINARY_SIZE), .HALF_SIZE(HALF_BINARY_SIZE)) SQRT101 (
    .input_Binary (op_a           ),
    .output_Binary(SQUARE_ROOT_OUT)
  );

  always @ (SQUARE_ROOT_OUT[0]) begin
    SQUARE_ROOT_DONE_FLAGE = 1;
  end

  always_comb begin
    if (SQUARE_ROOT_DONE_FLAGE) begin
      MANTISSA   = SQUARE_ROOT_OUT[51:0];
      DONE_FLAGE = 1;
    end
    else begin
      MANTISSA   = 0;
      DONE_FLAGE = 0;
    end
  end

endmodule : square_root_mantissa