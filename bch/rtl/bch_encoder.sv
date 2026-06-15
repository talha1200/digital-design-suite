///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2026 Talha Mahboob
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
`timescale 1ns / 1ps

// Purely combinational systematic BCH encoder.
// Codeword layout: o_codeword = {i_data[K-1:0], parity[N-K-1:0]}
// Parity is the remainder of (i_data * x^(N-K)) divided by GEN_POLY.
module bch_encoder #(
  parameter int           N        = 15, // codeword length
  parameter int           K        = 7 , // data bits
  parameter int           T        = 2 , // error-correction capability (used for validation)
  parameter int           GF_WIDTH = 4 , // GF(2^GF_WIDTH) field degree
  parameter logic [N-K:0] GEN_POLY = '0  // override; '0 selects built-in profile
) (
  input  logic [K-1:0] i_data    ,
  output logic [N-1:0] o_codeword
);

  import bch_pkg::*;

  //---------------------
  // local parameters
  //---------------------

  localparam int     R            = N - K;
  // Two-step evaluation: look up the 32-bit table entry, then narrow to [R:0].
  localparam [31:0]  POLY_LOOKUP  = default_gen_poly(N, K, T, GF_WIDTH);
  localparam [R:0]   ACTIVE_GEN_POLY =
    (GEN_POLY != '0) ? GEN_POLY : POLY_LOOKUP[R:0];

  //---------------------
  // elaboration checks
  //---------------------

  initial begin
    if ((R <= 0) || (ACTIVE_GEN_POLY[R] !== 1'b1) ||
        (ACTIVE_GEN_POLY[0] !== 1'b1) ||
        ((^ACTIVE_GEN_POLY) === 1'bx)) begin
      $fatal(1, "Unsupported BCH encoder parameters N=%0d K=%0d T=%0d GF_WIDTH=%0d",
             N, K, T, GF_WIDTH);
    end
  end

  //---------------------
  // LFSR parity function
  //---------------------

  function automatic logic [R-1:0] encode_parity(input logic [K-1:0] data);
    logic [R-1:0] lfsr;
    logic         feedback;
    begin
      lfsr = '0;
      for (int i = K - 1; i >= 0; i--) begin
        feedback = data[i] ^ lfsr[R-1];
        lfsr     = lfsr << 1;
        if (feedback) lfsr = lfsr ^ ACTIVE_GEN_POLY[R-1:0];
      end
      encode_parity = lfsr;
    end
  endfunction

  //---------------------
  // combinational output
  //---------------------

  assign o_codeword = {i_data, encode_parity(i_data)};

endmodule : bch_encoder
