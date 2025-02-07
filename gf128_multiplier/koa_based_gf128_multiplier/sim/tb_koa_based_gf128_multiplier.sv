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

module tb_koa_gf128_multiplier ();

  logic [128-1:0] A, B,P;
  logic [128-1:0] expected_P     ;

  koa_gf128_multiplier u_koa_gf128_multiplier (
    .A(A),
    .B(B),
    .P(P)
  );

  initial begin
    A     = 128'd0;
    B     = 128'd0;
    #10;
    // Test case 1
    A          = 128'h0388dace60b6a392f328c2b971b2fe78;
    B          = 128'h66e94bd4ef8a2c3b884cfa59ca342b2e;
    expected_P = 128'h5e2ec746917062882c85b0685353deb7;
    #10;
    if (P !== expected_P) $display("Test case 1 failed. P = %h, expected = %h", P, expected_P);
    else $display("Test case 1 passed");
    
    // Test case 2
    A = 128'h5e2ec746917062882c85b0685353de37;
    B = 128'h66e94bd4ef8a2c3b884cfa59ca342b2e;
    expected_P = 128'hf38cbb1ad69223dcc3457ae5b6b0f885;
    #10;
    if (P !== expected_P) $display("Test case 2 failed. P = %h, expected = %h", P, expected_P);
    else $display("Test case 2 passed");
    
    // Test case 3
    A = 128'hba471e049da20e40495e28e58ca8c555;
    B = 128'hb83b533708bf535d0aa6e52980d53b78;
    expected_P = 128'hb714c9048389afd9f9bc5c1d4378e052;
    #10;
    if (P !== expected_P) $display("Test case 3 failed. P = %h, expected = %h", P, expected_P);
    else $display("Test case 3 passed");
 
    // Test case 4
    A = 128'h66e94bd4ef8a2c3b884cfa59ca342b2e;
    B = 128'hff000000000000000000000000000000;
    expected_P = 128'h679d3cea2db93be5228724c2e2abea06;
    #10;
    if (P !== expected_P) $display("Test case 4 failed. P = %h, expected = %h", P, expected_P);
    else $display("Test case 4 passed");
    #10;
    $finish;
  end

endmodule : tb_koa_gf128_multiplier
