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


module tb_sync_fifo ();

  //---------------------------
  // Localparam
  //---------------------------
  parameter DATA_WIDTH = 8  ;
  parameter FIFO_DEPTH = 10 ;
  parameter SIM        = 1  ;

  //---------------------------
  // Internal wires and regs
  //---------------------------
  logic clk  ;
  logic rst_n;

  logic                  rd_en_0;
  logic                  wr_en_0;
  logic [DATA_WIDTH-1:0] din_0  ;
  logic                  empty_0;
  logic                  full_0 ;
  logic                  valid_0;
  logic [DATA_WIDTH-1:0] dout_0 ;
  logic enable_0   ;

  logic                  rd_en_1;
  logic                  wr_en_1;
  logic [DATA_WIDTH-1:0] din_1  ;
  logic                  empty_1;
  logic                  full_1 ;
  logic                  valid_1;
  logic [DATA_WIDTH-1:0] dout_1 ;
  logic enable_1   ;


  // ---------------------------------
  // Implementation
  // ---------------------------------

  // Instantiate the FIFO for Standard mode
  sync_fifo #(
    .SIM       (SIM       ),
    .DATA_WIDTH(DATA_WIDTH),
    .FIFO_DEPTH(FIFO_DEPTH),
    .FIFO_TYPE ("Standard")
  ) fifo_standard (
    .clk  (clk    ),
    .rst_n(rst_n  ),
    .rd_en(rd_en_0),
    .wr_en(wr_en_0),
    .din  (din_0  ),
    .empty(empty_0),
    .full (full_0 ),
    .valid(valid_0),
    .dout (dout_0 )
  );

  // Instantiate the FIFO for FWFT mode
  sync_fifo #(
    .SIM       (SIM       ),
    .DATA_WIDTH(DATA_WIDTH),
    .FIFO_DEPTH(FIFO_DEPTH),
    .FIFO_TYPE ("FWFT"    )
  ) fifo_fwft (
    .clk  (clk    ),
    .rst_n(rst_n  ),
    .rd_en(rd_en_1),
    .wr_en(wr_en_1),
    .din  (din_1  ),
    .empty(empty_1),
    .full (full_1 ),
    .valid(valid_1),
    .dout (dout_1 )
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // FIFO Tester instance
  fifo_tester #(.DATA_WIDTH(DATA_WIDTH), .FIFO_DEPTH(FIFO_DEPTH)) tester_0 (
    .clk      (clk      ),
    .rst_n    (rst_n    ),
    .enable   (enable_0 ),
    .dout     (dout_0   ),
    .full     (full_0   ),
    .empty    (empty_0  ),
    .valid    (valid_0  ),
    .wr_en    (wr_en_0  ),
    .rd_en    (rd_en_0  ),
    .din      (din_0    )
  );

  fifo_tester #(.DATA_WIDTH(DATA_WIDTH), .FIFO_DEPTH(FIFO_DEPTH)) tester_1 (
    .clk      (clk      ),
    .rst_n    (rst_n    ),
    .enable   (enable_1 ),
    .dout     (dout_1   ),
    .full     (full_1   ),
    .empty    (empty_1  ),
    .valid    (valid_1  ),
    .wr_en    (wr_en_1  ),
    .rd_en    (rd_en_1  ),
    .din      (din_1    )
  );

  // Test sequences
  initial begin
    enable_0  = 0;
    enable_1  = 0;
    rst_n     = 1;
    rd_en_0   = 0;
    wr_en_0   = 0;
    din_0     = 0;
    rd_en_1   = 0;
    wr_en_1   = 0;
    din_1     = 0;
    #20;
    rst_n     = 0;
    #20;
    rst_n     = 1;

    // Test Standard FIFO
    $display("Testing Standard FIFO");
    enable_0  = 1;
    repeat(10) @(posedge clk);
    enable_0  = 0;
    // Test FWFT FIFO
    $display("Testing FWFT FIFO");
    repeat(10) @(posedge clk);
    enable_1  = 1;
    repeat(10) @(posedge clk);
    enable_1  = 0;
    repeat(10) @(posedge clk);
    $finish;
  end


endmodule
