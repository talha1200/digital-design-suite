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

// Hamming SECDED decoder: AXI-Stream 13-bit input, 8-bit output
// Corrects single-bit errors; detects (but does not correct) double-bit errors.
module hamming_axis8_decoder (
  input  logic        clk                ,
  input  logic        rst_n              ,
  input  logic [12:0] s_axis_tdata       ,
  input  logic        s_axis_tvalid      ,
  output logic        s_axis_tready      ,
  input  logic        s_axis_tlast       ,
  output logic [ 7:0] m_axis_tdata       ,
  output logic        m_axis_tvalid      ,
  input  logic        m_axis_tready      ,
  output logic        m_axis_tlast       ,
  output logic        m_axis_corrected   ,
  output logic        m_axis_double_error,
  output logic [ 3:0] m_axis_syndrome
);

  //-------------------
  // local parameters and functions
  //-------------------

  function automatic logic [3:0] syndrome(input logic [11:0] code);
    logic s1, s2, s4, s8;
    begin
      s1 = code[0] ^ code[2] ^ code[4] ^ code[6] ^ code[8]  ^ code[10];
      s2 = code[1] ^ code[2] ^ code[5] ^ code[6] ^ code[9]  ^ code[10];
      s4 = code[3] ^ code[4] ^ code[5] ^ code[6] ^ code[11];
      s8 = code[7] ^ code[8] ^ code[9] ^ code[10] ^ code[11];
      syndrome = {s8, s4, s2, s1};
    end
  endfunction

  function automatic logic [7:0] extract_data(input logic [11:0] code);
    begin
      extract_data = {
        code[11], code[10], code[9], code[8],
        code[6],  code[5],  code[4], code[2]
      };
    end
  endfunction

  //-------------------
  // internal signals and registers
  //-------------------

  logic [ 3:0] syn             ;
  logic        overall_mismatch;
  logic [12:0] corrected_word  ;
  logic        corrected       ;
  logic        double_error    ;

  //-------------------
  // combinational logic
  //-------------------
  // Syndrome calculation and error correction logic
  // (combinational for zero-cycle latency; clk/rst_n are present for interface regularity)

  // clk/rst_n are present for interface regularity; logic is combinational.
  always_comb begin
    syn              = syndrome(s_axis_tdata[11:0]);
    overall_mismatch = ^s_axis_tdata;
    corrected_word   = s_axis_tdata;
    corrected        = 1'b0;
    double_error     = 1'b0;

    if ((syn != 4'd0) && overall_mismatch) begin
      // Single-bit error in one of the 12 Hamming-coded positions
      corrected_word[syn-4'd1] = ~corrected_word[syn - 4'd1];
      corrected                = 1'b1;
    end 
    else if ((syn == 4'd0) && overall_mismatch) begin
      // Single-bit error in the overall-parity bit (bit 12)
      corrected_word[12] = ~corrected_word[12];
      corrected          = 1'b1;
    end 
    else if ((syn != 4'd0) && !overall_mismatch) begin
      double_error = 1'b1;
    end

    s_axis_tready       = m_axis_tready;
    m_axis_tvalid       = s_axis_tvalid;
    m_axis_tlast        = s_axis_tlast;
    m_axis_syndrome     = syn;
    m_axis_corrected    = corrected;
    m_axis_double_error = double_error;
    m_axis_tdata        = extract_data(double_error ? s_axis_tdata[11:0] : corrected_word[11:0]);
  end

endmodule : hamming_axis8_decoder
