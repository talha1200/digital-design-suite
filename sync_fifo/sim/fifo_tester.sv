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

module fifo_tester #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 16
)(
    input  logic clk,
    input  logic rst_n,
    input  logic enable,
    input  logic [DATA_WIDTH-1:0] dout,
    input  logic full,
    input  logic empty,
    input  logic valid,
    output logic wr_en,
    output logic rd_en,
    output logic [DATA_WIDTH-1:0] din
);
  
  //---------------------------
  // Localparam
  //---------------------------

  //---------------------------
  // Internal wires and regs
  //---------------------------

  logic [$clog2(FIFO_DEPTH)-1:0] wrptr;
  logic [$clog2(FIFO_DEPTH)-1:0] rdptr;
  logic [DATA_WIDTH-1:0] sent_data [FIFO_DEPTH-1:0];
  logic [DATA_WIDTH-1:0] data;

  // ---------------------------------
  // Implementation
  // ---------------------------------

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      data <= {DATA_WIDTH{1'd0}};
    end
    else begin 
      data <= $urandom_range(0, (1 << DATA_WIDTH) - 1);
    end
  end

  // Synchronous logic to handle the reset and enable signals
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wrptr <= 0;
      wr_en <= 0;
    end
    else begin
      // Write data to FIFO
      if (!full && enable) begin
        wr_en            <= 1;
        din              <= data;
        sent_data[wrptr] <= data; // saving a copy
        wrptr            <= wrptr + 1;
      end 
      else begin
        wr_en <= 0;
        wrptr <= wrptr;
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      rd_en <= 0;
    end
    else begin
      // Read data from FIFO and compare with sent data
      if (!empty && enable) begin
        rd_en <= 1;
      end 
      else begin
        rd_en <= 0;
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      rdptr <= 0;
    end
    else begin
      if (valid) begin
        if (dout !== sent_data[rdptr]) begin
          $display("ERROR: Mismatch at index %0d: expected %0h, got %0h", rdptr, sent_data[rdptr], dout);
        end 
        else begin
          $display("Match at index %0d: data %0h", rdptr, dout);
        end
        rdptr <= rdptr + 1;
      end
    end
  end

endmodule
