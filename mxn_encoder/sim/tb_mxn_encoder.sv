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

module tb_mxn_encoder ();

  //-----------------------------------
  // local parameter
  //-----------------------------------

  // Parameters
  localparam DATA_WIDTH    = 16;
  localparam PRIORITY_TYPE = 0 ; // Change to 1 for MSB priority

  //-----------------------------------
  // wires and regs
  //-----------------------------------
  // Inputs
  logic [DATA_WIDTH-1:0] unencoded_data;

  // Outputs
  logic                          valid_out       ;
  logic [$clog2(DATA_WIDTH)-1:0] encoded_data_out;
  logic [                16-1:0] mismatch_cnt    ;


  //-------------------------------------
  // Implementation
  //-------------------------------------

  // Instantiate the Unit Under Test (UUT)
  mxn_encoder #(
    .DATA_WIDTH   (DATA_WIDTH   ),
    .PRIORITY_TYPE(PRIORITY_TYPE)
  ) uut (
    .unencoded_data  (unencoded_data  ),
    .valid_out       (valid_out       ),
    .encoded_data_out(encoded_data_out)
  );

  // Test cases
  initial begin
    // Initialize Inputs
    unencoded_data = 16'b0000000000000000; // 
    mismatch_cnt   = 16'd0;
    unencoded_data = 16'b0000000000000001;
    #10;
    $display("Input: %b, Output: %b SIM TIME: %t", unencoded_data,encoded_data_out,$time);
    if (encoded_data_out != 4'b0000) begin
      mismatch_cnt++;
    end
    
    unencoded_data = 16'b0000000000000010;
    #10;
    $display("Input: %b, Output: %b SIM TIME: %t", unencoded_data,encoded_data_out,$time);
    if (encoded_data_out != 4'b0001) begin
      mismatch_cnt++;
    end
    
    unencoded_data = 16'b0000000000000100;
    #10;
    $display("Input: %b, Output: %b SIM TIME: %t", unencoded_data,encoded_data_out,$time);
    if (encoded_data_out != 4'b0010) begin
      mismatch_cnt++;
    end
    
    unencoded_data = 16'b0000000000001000;
    #10;
    $display("Input: %b, Output: %b SIM TIME: %t", unencoded_data,encoded_data_out,$time);
    if (encoded_data_out != 4'b0011) begin
      mismatch_cnt++;
    end
    
    unencoded_data = 16'b0000000000010000;
    #10;
    $display("Input: %b, Output: %b SIM TIME: %t", unencoded_data,encoded_data_out,$time);
    if (encoded_data_out != 4'b0100) begin
      mismatch_cnt++;
    end
    
    unencoded_data = 16'b0000000000100000;
    #10;
    $display("Input: %b, Output: %b SIM TIME: %t", unencoded_data,encoded_data_out,$time);
    if (encoded_data_out != 4'b0101) begin
      mismatch_cnt++;
    end
    
    unencoded_data = 16'b0000000001000000;
    #10;
    $display("Input: %b, Output: %b SIM TIME: %t", unencoded_data,encoded_data_out,$time);
    if (encoded_data_out != 4'b0110) begin
      mismatch_cnt++;
    end
    
    unencoded_data = 16'b0000000010000000;
    #10;
    $display("Input: %b, Output: %b SIM TIME: %t", unencoded_data,encoded_data_out,$time);
    if (encoded_data_out != 4'b0111) begin
      mismatch_cnt++;
    end
    
    unencoded_data = 16'b0000000100000000;
    #10;
    $display("Input: %b, Output: %b SIM TIME: %t", unencoded_data,encoded_data_out,$time);
    if (encoded_data_out != 4'b1000) begin
      mismatch_cnt++;
    end
    
    unencoded_data = 16'b0000001000000000;
    #10;
    $display("Input: %b, Output: %b SIM TIME: %t", unencoded_data,encoded_data_out,$time);
    if (encoded_data_out != 4'b1001) begin
      mismatch_cnt++;
    end
    
    unencoded_data = 16'b0000010000000000;
    #10;
    $display("Input: %b, Output: %b SIM TIME: %t", unencoded_data,encoded_data_out,$time);
    if (encoded_data_out != 4'b1010) begin
      mismatch_cnt++;
    end
    
    unencoded_data = 16'b0000100000000000;
    #10;
    $display("Input: %b, Output: %b SIM TIME: %t", unencoded_data,encoded_data_out,$time);
    if (encoded_data_out != 4'b1011) begin
      mismatch_cnt++;
    end
    
    unencoded_data = 16'b0001000000000000;
    #10;
    $display("Input: %b, Output: %b SIM TIME: %t", unencoded_data,encoded_data_out,$time);
    if (encoded_data_out != 4'b1100) begin
      mismatch_cnt++;
    end
    
    unencoded_data = 16'b0010000000000000;
    #10;
    $display("Input: %b, Output: %b SIM TIME: %t", unencoded_data,encoded_data_out,$time);
    if (encoded_data_out != 4'b1101) begin
      mismatch_cnt++;
    end
    
    unencoded_data = 16'b0100000000000000;
    #10;
    $display("Input: %b, Output: %b SIM TIME: %t", unencoded_data,encoded_data_out,$time);
    if (encoded_data_out != 4'b1110) begin
      mismatch_cnt++;
    end
    
    unencoded_data = 16'b1000000000000000;
    #10;
    $display("Input: %b, Output: %b SIM TIME: %t", unencoded_data,encoded_data_out,$time);
    if (encoded_data_out != 4'b1111) begin
      mismatch_cnt++;
    end

    #10;
    if (mismatch_cnt != 0) begin
      $display("TEST FAILED mismatch_cnt = %d",mismatch_cnt);
      #10;
      $finish;    // Finish simulation
    end
    else begin 
      $display("TEST PASSED");
      #10;
      $finish;     // Finish simulation
    end
  end

endmodule : tb_mxn_encoder
