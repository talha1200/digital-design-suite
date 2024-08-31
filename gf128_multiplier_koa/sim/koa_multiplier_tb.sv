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

module tb_koa_multiplier ();

  //-------------
  // parameters
  //-------------
  // Parameters
  parameter DATA_WIDTH = 128;

  //-----------------
  // internal wires and regs
  //-----------------
  // Inputs to the DUT (Device Under Test)
  logic [DATA_WIDTH-1:0] Ai, Bi;
  // Output from the DUT
  logic [2*DATA_WIDTH-1:0] Do;
  // Traditional multiplier result for comparison
  logic [2*DATA_WIDTH-1:0] traditional_result;
  logic [  DATA_WIDTH-1:0] gf128_z           ;
  logic [  DATA_WIDTH-1:0] gf128_z_lsfr           ;
  logic [  DATA_WIDTH-1:0] gf_mult_y           ;

  //----------------
  // implementaion
  //----------------

  // Instantiate the DUT
  KOA_Multiplier_128bit u_koa_multiplier (
    .a      (Ai),
    .b      (Bi),
    .product(Do)
  );

  // not working currently
  ModularReduction u_ModularReduction (
    .in (Do     ),
    .out(gf128_z)
  );

  // Task to apply stimulus and check result
  task run_test(input logic [DATA_WIDTH-1:0] A, B);
    begin

      Ai = A;
      Bi = B;
      #1;
      // Calculate the expected result using traditional multiplication
      traditional_result = (A * B);

      // Compare the DUT output with the traditional multiplier result
      if (Do !== traditional_result) begin
        $display("Test FAILED for inputs A = %h, B = %h", A, B);
        $display("Expected: %h, Got: %h", traditional_result, Do);
      end else begin
        $display("Test PASSED for inputs A = %h, B = %h", A, B);
      end
    end
  endtask

  // Testbench
  initial begin
    // Edge Case 1: All zeros
    run_test(128'b0, 128'b0);
    #10;
    // Edge Case 2: All ones
    run_test({128{1'b1}}, {128{1'b1}});
    #10;

    // Edge Case 3: Alternating bits
    run_test(128'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA, 128'h55555555555555555555555555555555);
    #10;

    // Random Case 1
    run_test(128'hDEADBEEFCAFEBABE123456789ABCDEF0, 128'h0123456789ABCDEFDEADBEEFCAFEBABE);
    #10;

    // Random Case 2
    run_test(128'h11111111111111111111111111111111, 128'h22222222222222222222222222222222);
    #10;

    // Random Case 3
    run_test(128'hFEDCBA98765432100123456789ABCDEF,128'hABCDEF0123456789FEDCBA9876543210);
    #10;

    // End of Test
    $display("All tests completed.");
    #10;
    $stop;
  end
endmodule : tb_koa_multiplier
