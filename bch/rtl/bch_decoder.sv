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

// Purely combinational systematic BCH decoder (T <= 2).
//
// Decoding pipeline (all combinational):
//   1. Syndrome   — divide i_rx_word by GEN_POLY; zero syndrome means clean.
//   2. Error locate — brute-force search: all weight-1 masks, then weight-2
//      masks (when T>=2). O(N^2) combinations; practical for small N only.
//      A production decoder would use Berlekamp-Massey + Chien search.
//   3. Correction  — XOR i_rx_word with the matching mask.
//   4. Data extract — upper K bits of the corrected word (systematic layout).
//
// Latency: 0 cycles (combinational).
module bch_decoder #(
  parameter int           N        = 15, // codeword length
  parameter int           K        = 7 , // data bits
  parameter int           T        = 2 , // error-correction capability
  parameter int           GF_WIDTH = 4 , // GF(2^GF_WIDTH) field degree
  parameter logic [N-K:0] GEN_POLY = '0  // override; '0 selects built-in profile
) (
  input  logic [N-1:0] i_rx_word      ,
  output logic [K-1:0] o_data         ,
  output logic         o_uncorrectable
);

  import bch_pkg::*;

  //---------------------
  // local parameters
  //---------------------

  localparam int    R           = N - K;
  localparam [31:0] POLY_LOOKUP = default_gen_poly(N, K, T, GF_WIDTH);
  localparam [R:0]  ACTIVE_GEN_POLY =
    (GEN_POLY != '0) ? GEN_POLY : POLY_LOOKUP[R:0];

  //---------------------
  // elaboration checks
  //---------------------

  initial begin
    if ((R <= 0) || (T > 2) || (ACTIVE_GEN_POLY[R] !== 1'b1) ||
        (ACTIVE_GEN_POLY[0] !== 1'b1) ||
        ((^ACTIVE_GEN_POLY) === 1'bx)) begin
      $fatal(1, "Unsupported BCH decoder parameters N=%0d K=%0d T=%0d GF_WIDTH=%0d",
             N, K, T, GF_WIDTH);
    end
  end

  //---------------------
  // syndrome function
  //---------------------

  function automatic logic [R-1:0] calc_syndrome(input logic [N-1:0] word);
    logic [R-1:0] rem;
    logic         feedback;
    begin
      rem = '0;
      for (int i = N - 1; i >= 0; i--) begin
        feedback = word[i] ^ rem[R-1];
        rem      = rem << 1;
        if (feedback) rem = rem ^ ACTIVE_GEN_POLY[R-1:0];
      end
      calc_syndrome = rem;
    end
  endfunction

  //---------------------
  // single-bit mask helper
  //---------------------

  function automatic logic [N-1:0] bit_mask(input int index);
    begin
      bit_mask = '0;
      if ((index >= 0) && (index < N)) bit_mask[index] = 1'b1;
    end
  endfunction

  //---------------------
  // error-locate function
  // Returns {found[0], correction_mask[N-1:0]} packed into N+1 bits.
  // found=1 means a correctable pattern was found; correction_mask is XOR'd
  // onto the received word. found=0 means uncorrectable (>T errors).
  //---------------------

  function automatic logic [N:0] locate_error(input logic [R-1:0] target);
    logic [N-1:0] candidate;
    logic [N-1:0] found_mask;
    logic         found;
    begin
      found      = (target == '0);   // zero syndrome — no errors
      found_mask = '0;

      // Weight-1 search
      for (int i = 0; i < N; i++) begin
        candidate = bit_mask(i);
        if (!found && (calc_syndrome(candidate) == target)) begin
          found      = 1'b1;
          found_mask = candidate;
        end
      end

      // Weight-2 search (only when T >= 2)
      if (T >= 2) begin
        for (int i = 0; i < N; i++) begin
          for (int j = i + 1; j < N; j++) begin
            candidate = bit_mask(i) ^ bit_mask(j);
            if (!found && (calc_syndrome(candidate) == target)) begin
              found      = 1'b1;
              found_mask = candidate;
            end
          end
        end
      end

      locate_error = {found, found_mask};
    end
  endfunction

  //---------------------
  // internal wires
  //---------------------

  logic [R-1:0] w_syndrome    ;
  logic [  N:0] w_error_result; // [N]=found flag, [N-1:0]=correction mask
  logic [N-1:0] w_corrected   ;

  //---------------------
  // combinational pipeline
  //---------------------

  assign w_syndrome     = calc_syndrome(i_rx_word);
  assign w_error_result = locate_error(w_syndrome);
  assign w_corrected    = i_rx_word ^ w_error_result[N-1:0];
  assign o_data         = w_corrected[N-1:R]; // data in MSBs (systematic encoding)
  assign o_uncorrectable = !w_error_result[N];

endmodule : bch_decoder
