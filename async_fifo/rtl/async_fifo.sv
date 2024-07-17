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

module async_fifo #(
  parameter DATA_WIDTH = 8              ,
  parameter ADDR_WIDTH = 4              ,
  parameter DEPTH      = 1 << ADDR_WIDTH  // FIFO depth is 2^ADDR_WIDTH
) (
  input  logic                  wr_clk   , // Write clock
  input  logic                  rd_clk   , // Read clock
  input  logic                  rst      , // Reset signal
  input  logic                  wr_en    , // Write enable
  input  logic                  rd_en    , // Read enable
  input  logic [DATA_WIDTH-1:0] din      , // Data input
  output logic                  vaild_out,
  output logic [DATA_WIDTH-1:0] dout     , // Data output
  output logic                  full     ,
  output logic                  empty
);

  
  //--------------------------------
  // local parameter
  //--------------------------------

  //--------------------------------
  // internal wire & reg
  //--------------------------------

  logic [DATA_WIDTH-1:0] fifo_mem[DEPTH-1:0]; // FIFO memory array
  logic [ADDR_WIDTH:0] wr_ptr_bin, wr_ptr_gray, rd_ptr_bin, rd_ptr_gray;
  logic [ADDR_WIDTH:0] wr_ptr_gray_sync1, wr_ptr_gray_sync2, rd_ptr_gray_sync1, rd_ptr_gray_sync2;

  //--------------------------------
  // implemetation
  //--------------------------------

  // Binary to Gray code conversion
  function [ADDR_WIDTH:0] bin2gray(input [ADDR_WIDTH:0] bin);
    bin2gray = bin ^ (bin >> 1);
  endfunction

  // Gray to Binary code conversion
  function [ADDR_WIDTH:0] gray2bin(input [ADDR_WIDTH:0] gray);
    integer i;
    begin
      gray2bin = gray;
      for (i = ADDR_WIDTH-1; i >= 0; i = i - 1) begin
        gray2bin[i] = gray2bin[i] ^ gray[i+1];
      end
    end
  endfunction

  // Write pointer logic (in the write clock domain)
  always_ff @(posedge wr_clk or posedge rst) begin
    if (rst) begin
      wr_ptr_bin  <= 0;
      wr_ptr_gray <= 0;
    end else if (wr_en && !full) begin
      wr_ptr_bin  <= wr_ptr_bin + 1;
      wr_ptr_gray <= bin2gray(wr_ptr_bin + 1);
    end
  end

  // Read pointer logic (in the read clock domain)
  always_ff @(posedge rd_clk or posedge rst) begin
    if (rst) begin
      rd_ptr_bin  <= 0;
      rd_ptr_gray <= 0;
    end else if (rd_en && !empty) begin
      rd_ptr_bin  <= rd_ptr_bin + 1;
      rd_ptr_gray <= bin2gray(rd_ptr_bin + 1);
    end
  end

  // Synchronizing write pointer to read clock domain
  always_ff @(posedge rd_clk or posedge rst) begin
    if (rst) begin
      wr_ptr_gray_sync1 <= 0;
      wr_ptr_gray_sync2 <= 0;
    end else begin
      wr_ptr_gray_sync1 <= wr_ptr_gray;
      wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
    end
  end

  // Synchronizing read pointer to write clock domain
  always_ff @(posedge wr_clk or posedge rst) begin
    if (rst) begin
      rd_ptr_gray_sync1 <= 0;
      rd_ptr_gray_sync2 <= 0;
    end else begin
      rd_ptr_gray_sync1 <= rd_ptr_gray;
      rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
    end
  end

  // Memory write operation
  always_ff @(posedge wr_clk) begin
    if (wr_en && !full) begin
      fifo_mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= din;
    end
  end

  // Memory read operation
  always_ff @(posedge rd_clk or posedge rst) begin
    if (rst) begin
      dout <= {DATA_WIDTH{1'b0}};
    end
    else begin
      if (rd_en && !empty) begin
        dout <= fifo_mem[rd_ptr_bin[ADDR_WIDTH-1:0]];
      end
    end
  end

  always_ff @(posedge rd_clk or posedge rst) begin 
    if(rst) begin
      vaild_out <= 0;
    end 
    else begin
      vaild_out <= rd_en;
    end
  end

  // Full condition: write pointer + 1 == read pointer (in Gray code form)
  assign full = (wr_ptr_gray == {~rd_ptr_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1], rd_ptr_gray_sync2[ADDR_WIDTH-2:0]});

  // Empty condition: write pointer == read pointer (in Gray code form)
  assign empty = (wr_ptr_gray_sync2 == rd_ptr_gray);

endmodule
