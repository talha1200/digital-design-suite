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
`timescale 1ns/1ps
// Testbench for hamming_axis8_encoder and hamming_axis8_decoder.
// Tests:
//   1. Clean encode/decode roundtrip for all 256 input bytes.
//   2. Single-bit error correction across all 13 bit positions.
//   3. Double-bit error detection across all C(13,2) pairs.
module tb_hamming ();

  // Encoder DUT signals
  logic clk, rst_n;

  logic [ 7:0] enc_s_tdata ;
  logic        enc_s_tvalid, enc_s_tready, enc_s_tlast;
  logic [12:0] enc_m_tdata ;
  logic        enc_m_tvalid, enc_m_tready, enc_m_tlast;

  // Decoder DUT signals
  logic [12:0] dec_s_tdata    ;
  logic        dec_s_tvalid, dec_s_tready, dec_s_tlast;
  logic [ 7:0] dec_m_tdata    ;
  logic        dec_m_tvalid, dec_m_tready, dec_m_tlast;
  logic        dec_m_corrected, dec_m_double_error;
  logic [ 3:0] dec_m_syndrome ;

  // DUT instances
  hamming_axis8_encoder u_enc (
    .clk          (clk         ),
    .rst_n        (rst_n       ),
    .s_axis_tdata (enc_s_tdata ),
    .s_axis_tvalid(enc_s_tvalid),
    .s_axis_tready(enc_s_tready),
    .s_axis_tlast (enc_s_tlast ),
    .m_axis_tdata (enc_m_tdata ),
    .m_axis_tvalid(enc_m_tvalid),
    .m_axis_tready(enc_m_tready),
    .m_axis_tlast (enc_m_tlast )
  );

  hamming_axis8_decoder u_dec (
    .clk                (clk               ),
    .rst_n              (rst_n             ),
    .s_axis_tdata       (dec_s_tdata       ),
    .s_axis_tvalid      (dec_s_tvalid      ),
    .s_axis_tready      (dec_s_tready      ),
    .s_axis_tlast       (dec_s_tlast       ),
    .m_axis_tdata       (dec_m_tdata       ),
    .m_axis_tvalid      (dec_m_tvalid      ),
    .m_axis_tready      (dec_m_tready      ),
    .m_axis_tlast       (dec_m_tlast       ),
    .m_axis_corrected   (dec_m_corrected   ),
    .m_axis_double_error(dec_m_double_error),
    .m_axis_syndrome    (dec_m_syndrome    )
  );

  // Clock and AXI-Stream tie-offs
  initial clk = 0;
  always #5 clk = ~clk;

  assign enc_s_tvalid = 1'b1;
  assign enc_s_tlast  = 1'b0;
  assign enc_m_tready = 1'b1;
  assign dec_s_tvalid = 1'b1;
  assign dec_s_tlast  = 1'b0;
  assign dec_m_tready = 1'b1;

  // Test state
  int          pass_cnt, fail_cnt;
  logic [12:0] cw, corrupted;
  logic [ 7:0] byte_out ;
  logic        corr_flag, derr_flag;
  logic [ 3:0] syn_out  ;

  // Both DUTs are purely combinational; drive input and sample after #1.
  task automatic t_encode(input logic [7:0] data, output logic [12:0] out_cw);
    enc_s_tdata = data;
    #1;
    out_cw = enc_m_tdata;
  endtask

  task automatic t_decode(
      input  logic [12:0] in_cw,
      output logic [7:0]  data,
      output logic        corrected,
      output logic        double_err,
      output logic [3:0]  syn
    );
    dec_s_tdata = in_cw;
    #1;
    data       = dec_m_tdata;
    corrected  = dec_m_corrected;
    double_err = dec_m_double_error;
    syn        = dec_m_syndrome;
  endtask

  // Main test sequence
  initial begin
    pass_cnt    = 0;
    fail_cnt    = 0;
    rst_n       = 0;
    enc_s_tdata = 0;
    dec_s_tdata = 0;
    #20;
    rst_n = 1;
    #5;

    // Test 1: clean roundtrip, all 256 bytes
    $display("[TEST 1] Clean encode/decode roundtrip (all 256 bytes)");
    for (int i = 0; i < 256; i++) begin
      t_encode(i[7:0], cw);
      t_decode(cw, byte_out, corr_flag, derr_flag, syn_out);
      if (byte_out !== i[7:0] || corr_flag !== 1'b0 || derr_flag !== 1'b0) begin
        $display("  FAIL  data=0x%02h  cw=0x%04h  out=0x%02h  corr=%b  derr=%b",
          i[7:0], cw, byte_out, corr_flag, derr_flag);
        fail_cnt++;
      end else
      pass_cnt++;
    end

    // Test 2: single-bit error correction, all 13 positions
    $display("[TEST 2] Single-bit error correction  (data=0xA5, 13 positions)");
    t_encode(8'hA5, cw);
    for (int b = 0; b < 13; b++) begin
      corrupted = cw ^ (13'h1 << b);
      t_decode(corrupted, byte_out, corr_flag, derr_flag, syn_out);
      if (byte_out !== 8'hA5 || corr_flag !== 1'b1 || derr_flag !== 1'b0) begin
        $display("  FAIL  bit=%0d  orig=0x%04h  corrupt=0x%04h  out=0x%02h  corr=%b  derr=%b",
          b, cw, corrupted, byte_out, corr_flag, derr_flag);
        fail_cnt++;
      end else
      pass_cnt++;
    end

    // Test 3: double-bit error detection, all C(13,2) pairs
    $display("[TEST 3] Double-bit error detection  (data=0x3C, 78 pairs)");
    t_encode(8'h3C, cw);
    for (int b0 = 0; b0 < 13; b0++) begin
      for (int b1 = b0 + 1; b1 < 13; b1++) begin
        corrupted = cw ^ (13'h1 << b0) ^ (13'h1 << b1);
        t_decode(corrupted, byte_out, corr_flag, derr_flag, syn_out);
        if (derr_flag !== 1'b1 || corr_flag !== 1'b0) begin
          $display("  FAIL  bits=%0d,%0d  orig=0x%04h  corrupt=0x%04h  derr=%b  corr=%b",
            b0, b1, cw, corrupted, derr_flag, corr_flag);
          fail_cnt++;
        end else
        pass_cnt++;
      end
    end

    // Summary
    $display("");
    $display("=== Results: PASS=%0d  FAIL=%0d ===", pass_cnt, fail_cnt);
    if (fail_cnt == 0) begin
      $display("ALL TESTS PASSED");
      $finish;
    end else begin
      $display("SOME TESTS FAILED");
      $fatal(1, "Hamming SECDED testbench failed");
    end
  end

endmodule : tb_hamming
