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
//In this module all the required equation for the
//Calculation of Square Root is implemented as decribe in the given research paper

module square_root_binary #(
  parameter SIZE      = 8'd108, // Size of Mantissa Product
  parameter HALF_SIZE = 8'd54   //Half Size of Mantissa Product
) (
  input  logic [     SIZE-1:0] input_Binary ,
  output logic [HALF_SIZE-1:0] output_Binary
);

  //-------------------
  // internal wires & regs
  //-------------------
  logic [SIZE-1:0] Q[0:HALF_SIZE-1];
  logic [SIZE-1:0] d[0:HALF_SIZE-1];

  //-------------------
  // implementation
  //-------------------

  equation4 u0_equation4 (input_Binary[SIZE-2],Q[HALF_SIZE-1][SIZE-1],Q[HALF_SIZE-1][SIZE-2],d[HALF_SIZE-1][SIZE-2]);
  equation5 u0_equation5 (input_Binary[SIZE-1],Q[HALF_SIZE-1][SIZE-2],Q[HALF_SIZE-1][SIZE-1],Q[HALF_SIZE-1][SIZE-1],d[HALF_SIZE-1][SIZE-1]);
  assign output_Binary[HALF_SIZE-1] = ~Q[HALF_SIZE-1][SIZE-1];

  generate
    genvar k; //Genvar is variable tpye used in 'generate' block
    if (SIZE > 2) begin
      equation1 u0_equation1 (input_Binary[0], Q[0][0], d[0][0]);
      equation2 u0_equation2 (input_Binary[1],Q[0][0],Q[0][1],d[0][1]);
      for (k = 1; k <= HALF_SIZE - 1; k = k + 1) begin
        equation3 Eq_3 (d[1][(SIZE - 1) - (HALF_SIZE - 2) - k], //r
          output_Binary[HALF_SIZE - k], // y
          Q[0][(SIZE - 1) - (HALF_SIZE - 2) - k - 1], // b
          Q[0][(SIZE - 1) - (HALF_SIZE - 2) - k], //Q
          d[0][(SIZE - 1) - (HALF_SIZE - 2) - k]  //d
        );
      end
      equation2 u1_equation2(d[1][(SIZE - 1) - (HALF_SIZE - 2)], Q[0][(SIZE - 1) - (HALF_SIZE - 2) - 1], Q[0][(SIZE - 1) - (HALF_SIZE - 2)], d[0][(SIZE - 1) - (HALF_SIZE - 2)]);
      assign output_Binary[0] = ~Q[0][(SIZE - 1) - (HALF_SIZE - 2)];
    end
  endgenerate

  generate
    genvar i, j;
    if (SIZE > 4) begin
      for (i = 0; i <= HALF_SIZE - 3; i = 1 + i) begin
        equation4 u1_equation4 (input_Binary[(SIZE - 4) - i*2], //r
          Q[(HALF_SIZE - 2) - i][(SIZE - 1) - i], // output_Binary
          Q[(HALF_SIZE - 2) - i][(SIZE - 4) - i*2], //Q
          d[(HALF_SIZE - 2) - i][(SIZE - 4) - i*2] //d
        );
        equation5 u1_equation5 (
          input_Binary[(SIZE - 3) - i*2],  //r
          Q[(HALF_SIZE - 2) - i][(SIZE - 4) - i*2], // b
          Q[(HALF_SIZE - 2) - i][(SIZE - 1) - i], //output_Binary
          Q[(HALF_SIZE - 2) - i][(SIZE - 3) - i*2], //Q
          d[(HALF_SIZE - 2) - i][(SIZE - 3) - i*2] // d
        );
        for (j = 1; j <= i + 1; j = 1 + j) begin
          equation0 u0_equation0 (d[(HALF_SIZE - 1) - i][(SIZE - 1) - i - j], // r
            output_Binary[HALF_SIZE - j], // y
            Q[(HALF_SIZE - 2) - i][(SIZE - 1) - i - (j + 1)], // b
            Q[(HALF_SIZE - 2) - i][(SIZE - 1) - i], // output_Binary
            Q[(HALF_SIZE - 2) - i][(SIZE - 1) - i - j], // Q
            d[(HALF_SIZE - 2) - i][(SIZE - 1) - i - j]  // d
          );
        end
        equation2 u1_equation2 (d[(HALF_SIZE - 1) - i][(SIZE - 1) - i], //r
          Q[(HALF_SIZE - 2) - i][(SIZE - 1) - i - 1], //b
          Q[(HALF_SIZE - 2) - i][(SIZE - 1) - i], // Q
          d[(HALF_SIZE - 2) - i][(SIZE - 1) - i] // d
        );
        assign output_Binary[(HALF_SIZE-2)-i] = ~Q[(HALF_SIZE - 2) - i][(SIZE - 1) - i];
      end
    end
  endgenerate

endmodule : square_root_binary