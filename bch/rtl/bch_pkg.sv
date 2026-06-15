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

// Shared constants and utilities for the BCH encoder/decoder pair.
package bch_pkg;

  // Returns the (R+1)-bit generator polynomial for built-in BCH profiles.
  // Returns 32'b0 for unknown profiles — caller must pass GEN_POLY explicitly.
  // Caller slices the result to [R:0]; unused high bits are always zero.
  function automatic logic [31:0] default_gen_poly(
    input int unsigned n,
    input int unsigned k,
    input int unsigned t,
    input int unsigned gf_width
  );
    default_gen_poly = 32'b0;
    if (n == 15 && k == 7  && t == 2 && gf_width == 4)
      default_gen_poly = 32'(9'b1_1101_0001);   // BCH(15,7,2) g(x) over GF(2^4)
    if (n == 26 && k == 16 && t == 2 && gf_width == 5)
      default_gen_poly = 32'(11'b111_0110_1001); // BCH(26,16,2) g(x) over GF(2^5)
  endfunction

endpackage : bch_pkg
