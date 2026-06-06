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
  localparam TEST_ITEMS = 64             ;

  //--------------------------------
  // internal wire & reg
  //--------------------------------
  // Clocks
  logic wr_clk;
  logic rd_clk;
  // Reset signal
  logic rst;
  // FIFO signals
  logic                  wr_en    ;
  logic                  rd_en    ;
  logic [DATA_WIDTH-1:0] din      ;
  logic                  vaild_out;
  logic [DATA_WIDTH-1:0] dout     ;
  logic                  full     ;
  logic                  empty    ;
  logic                  overflow ;
  logic                  underflow;
  // Internal signals for testbench
  logic [DATA_WIDTH-1:0] expected_data[TEST_ITEMS-1:0];
  int                    write_count             ;
  int                    read_count              ;
  int                    mismatch_cnt            ;

  //--------------------------------
  // implemetation
  //--------------------------------

  // Instantiate the asynchronous FIFO module
  async_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .DEPTH     (DEPTH     )
  ) dut (
    .wr_clk   (wr_clk   ),
    .rd_clk   (rd_clk   ),
    .rst      (rst      ),
    .wr_en    (wr_en    ),
    .rd_en    (rd_en    ),
    .din      (din      ),
    .vaild_out(vaild_out),
    .dout     (dout     ),
    .full     (full     ),
    .empty    (empty    ),
    .overflow (overflow ),
    .underflow(underflow)
  );

  // Clock generation
  always #5 wr_clk = ~wr_clk;  // Write clock period of 10 ns (100 MHz)
  always #10 rd_clk = ~rd_clk; // Read clock period of 20 ns (50 MHz)

  initial begin
    wr_clk       = 0;
    rd_clk       = 0;
    wr_en        = 0;
    rd_en        = 0;
    din          = '0;
    write_count  = 0;
    read_count   = 0;
    mismatch_cnt = 0;
    rst          = 1;
    #50;
    rst          = 0;
  end

  initial begin
    wait(!rst);
    while (write_count < TEST_ITEMS) begin
      @(negedge wr_clk);
      if (!full) begin
        din = write_count[DATA_WIDTH-1:0];
        wr_en = 1'b1;
        expected_data[write_count] = write_count[DATA_WIDTH-1:0];
        write_count++;
      end
      else begin
        wr_en = 1'b0;
      end
    end
    @(negedge wr_clk);
    wr_en = 1'b0;
  end

  initial begin
    wait(!rst);
    forever begin
      @(negedge rd_clk);
      rd_en = (read_count < TEST_ITEMS) && !empty;
    end
  end

  initial begin
    wait(!rst);
    while (read_count < TEST_ITEMS) begin
      @(posedge rd_clk);
      #1;
      if (vaild_out) begin
        if (dout !== expected_data[read_count]) begin
          $display("Data mismatch at index %0d! Expected: %h, received: %h",
                   read_count, expected_data[read_count], dout);
          mismatch_cnt++;
        end
        else begin
          $display("Data match at index %0d: %h", read_count, dout);
        end
        read_count++;
      end
    end
    if (mismatch_cnt > 0) begin
      $display("TEST FAILED");
    end
    else begin
      $display("TEST PASSED");
    end
    $finish;
  end

endmodule
