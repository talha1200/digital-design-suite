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

module sync_fifo #(
  parameter        SIM        = 1         ,
  parameter        DATA_WIDTH = 8         ,
  parameter        FIFO_DEPTH = 256       ,
  parameter string FIFO_TYPE  = "Standard"  // "Standard" or "FWFT"
) (
  input  logic                  clk  ,
  input  logic                  rst_n,
  input  logic                  rd_en,
  input  logic                  wr_en,
  input  logic [DATA_WIDTH-1:0] din  ,
  output logic                  empty,
  output logic                  full ,
  output logic                  valid,
  output logic [DATA_WIDTH-1:0] dout
);

  //---------------------------
  // Localparam
  //---------------------------
  localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);

  //---------------------------
  // Internal wires and regs
  //---------------------------
  logic [ADDR_WIDTH-1:0] wr_ptr                      ;
  logic [ADDR_WIDTH-1:0] rd_ptr                      ;
  logic [DATA_WIDTH-1:0] memory_block[FIFO_DEPTH-1:0];

  // ---------------------------------
  // Implementation
  // ---------------------------------

  generate
    if (SIM) begin
      initial begin
        for (int i = 0; i < FIFO_DEPTH; i++) begin
          memory_block[i] = {DATA_WIDTH{1'd0}};
        end
      end
    end
  endgenerate

  // Write pointer increments with every write unless the FIFO is full
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      wr_ptr <= 'h0;
    else if (wr_en && !full) begin
      if (wr_ptr == (FIFO_DEPTH - 1)) begin 
        wr_ptr <= 'h0;
      end
      else begin 
        wr_ptr <= wr_ptr + 1;
      end
    end
  end

  // Read pointer increments with every read unless the FIFO is empty
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      rd_ptr <= 'h0;
    else if (rd_en && !empty) begin
      if (rd_ptr == (FIFO_DEPTH - 1)) begin 
        rd_ptr <= 'h0;
      end
      else begin 
        rd_ptr <= rd_ptr + 1;
      end
    end
  end

  assign empty = rd_ptr == wr_ptr;
  assign full  = (wr_ptr + 1) == rd_ptr;;

  // Memory block for buffer
  always_ff @(posedge clk) begin
    if (wr_en && !full) begin
      memory_block[wr_ptr] <= din;
    end
  end

  // Output logic for Standard and FWFT modes
  generate
    if (FIFO_TYPE == "FWFT") begin
      always_comb begin
        if (rd_en) begin
          dout  = memory_block[rd_ptr];
          valid = 1'd1;
        end
        else begin
          valid = 1'd0;
          dout  = memory_block[rd_ptr];
        end
      end
    end
    else if (FIFO_TYPE == "Standard") begin
      always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
          dout  <= {DATA_WIDTH{1'd0}};
          valid <= 1'd0;
        end
        else begin
          if (rd_en && !empty) begin
            dout <= memory_block[rd_ptr];
            valid <= 1'd1;
          end
          else begin
            valid <= 1'd0;
          end
        end
      end
    end
    else begin
      $fatal("Wrong FIFO type. Fatal error occurred!");
    end
  endgenerate

endmodule
