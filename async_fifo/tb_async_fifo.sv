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

module tb_async_fifo ();

  //--------------------------------
  // local parameter
  //--------------------------------
  localparam DATA_WIDTH = 8              ;
  localparam ADDR_WIDTH = 4              ;
  localparam DEPTH      = 1 << ADDR_WIDTH; // FIFO depth is 2^ADDR_WIDTH

  //--------------------------------
  // internal wire & reg
  //--------------------------------
  // Clocks
  logic wr_clk;
  logic rd_clk;
  // Reset signal
  logic rst;
  // FIFO signals
  logic                  wr_en;
  logic                  rd_en;
  logic [DATA_WIDTH-1:0] din  ;
  logic [DATA_WIDTH-1:0] dout ;
  logic                  full ;
  logic                  empty;
  // Internal signals for testbench
  logic          [DATA_WIDTH-1:0] expected_data    ;
  int   unsigned                  data_count    = 0;

  //--------------------------------
  // implemetation
  //--------------------------------
  
  // Instantiate the asynchronous FIFO module
  async_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .DEPTH     (DEPTH     )
  ) dut (
    .wr_clk(wr_clk),
    .rd_clk(rd_clk),
    .rst   (rst   ),
    .wr_en (wr_en ),
    .rd_en (rd_en ),
    .din   (din   ),
    .dout  (dout  ),
    .full  (full  ),
    .empty (empty )
  );

  // Clock generation
  always #5 wr_clk = ~wr_clk;  // Write clock period of 10 ns (100 MHz)
  always #10 rd_clk = ~rd_clk; // Read clock period of 20 ns (50 MHz)

  // Testbench logic
  initial begin
    // Initialize signals
    wr_clk = 0;
    rd_clk = 0;
    rst = 1; // Assert reset

    // Reset the FIFO
    @(negedge wr_clk);
    rst = 0;
    @(negedge wr_clk);
    rst = 1;

    // Generate and send random data to DUT
    repeat (100) begin // Send 100 random data items
      @(negedge wr_clk);

      // Generate random data and send to DUT
      if (!full) begin
        din = $urandom_range(0, $urandom_range(0, (1 << DATA_WIDTH)-1));
        wr_en = 1;
        expected_data[data_count] = din;
        data_count++;
      end else begin
        wr_en = 0;
      end
    end

    // Read data from DUT and compare with expected data
    repeat (100) begin // Read 100 data items
      @(negedge rd_clk);

      // Read from DUT
      if (!empty && data_count > 0) begin
        rd_en = 1;
        if (dout !== expected_data[0]) begin
          $display("Data mismatch! Expected: %h, Received: %h", expected_data[0], dout);
          $stop;
        end
        data_count--;
      end else begin
        rd_en = 0;
      end
    end

    // End simulation
    $display("Simulation complete");
    $finish;
  end

endmodule
