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

// Hamming SECDED encoder: AXI-Stream 8-bit input, 13-bit output
// Bit layout (bit 0 = LSB):
//   bit:  12  11  10   9   8   7   6   5   4   3   2   1   0
//   field: P  d7  d6  d5  d4  p8  d3  d2  d1  p4  d0  p2  p1
module hamming_axis8_encoder (
  input  logic        clk          ,
  input  logic        rst_n        ,
  input  logic [ 7:0] s_axis_tdata ,
  input  logic        s_axis_tvalid,
  output logic        s_axis_tready,
  input  logic        s_axis_tlast ,
  output logic [12:0] m_axis_tdata ,
  output logic        m_axis_tvalid,
  input  logic        m_axis_tready,
  output logic        m_axis_tlast
);

  //-------------------
  // local parameters and functions
  //-------------------

  function automatic logic [12:0] encode_byte(input logic [7:0] data);
    logic [11:0] code;
    logic        p1, p2, p4, p8, overall;
    begin
      p1 = data[0] ^ data[1] ^ data[3] ^ data[4] ^ data[6];
      p2 = data[0] ^ data[2] ^ data[3] ^ data[5] ^ data[6];
      p4 = data[1] ^ data[2] ^ data[3] ^ data[7];
      p8 = data[4] ^ data[5] ^ data[6] ^ data[7];

      code = {
        data[7], data[6], data[5], data[4], p8,
        data[3], data[2], data[1], p4, data[0], p2, p1
      };
      overall = ^code;
      encode_byte = {overall, code};
    end
  endfunction

  //-------------------
  // combinational logic
  //-------------------

  // clk/rst_n are present for interface regularity; logic is combinational.
  assign s_axis_tready = m_axis_tready;
  assign m_axis_tvalid = s_axis_tvalid;
  assign m_axis_tdata  = encode_byte(s_axis_tdata);
  assign m_axis_tlast  = s_axis_tlast;

endmodule : hamming_axis8_encoder
