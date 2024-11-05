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
  parameter        SIMULATION = 1         ,
  parameter        DATA_WIDTH = 8         ,
  parameter        FIFO_DEPTH = 256       ,
  parameter string FIFO_TYPE  = "Standard" // "Standard" or "FWFT"
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
  logic [ADDR_WIDTH:0] wr_ptr_ext; // Extended write pointer with extra bit
  logic [ADDR_WIDTH:0] rd_ptr_ext; // Extended read pointer with extra bit
  logic [DATA_WIDTH-1:0] memory_block[FIFO_DEPTH-1:0];

  // ---------------------------------
  // Implementation
  // ---------------------------------

  generate
    if (SIMULATION) begin
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
      wr_ptr_ext <= 'h0;
    else if (wr_en && !full) begin
      wr_ptr_ext <= wr_ptr_ext + 1;
    end
  end

  // Read pointer increments with every read unless the FIFO is empty
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      rd_ptr_ext <= 'h0;
    else if (rd_en && !empty) begin
      rd_ptr_ext <= rd_ptr_ext + 1;
    end
  end

  // Full and empty conditions

  // - **Empty Condition**: The FIFO is empty when the extended write pointer (`wr_ptr_ext`) 
  //                        is equal to the extended read pointer (`rd_ptr_ext`). 
  //                        This means no data is available for reading.
  
  // - **Full Condition**:  The FIFO is full when the lower bits of the write pointer are equal 
  //                        to the lower bits of the read pointer, and the MSBs are different. 
  //                        This indicates that the write pointer has wrapped around and 
  //                        is one position behind the read pointer.

  
  assign empty = (wr_ptr_ext == rd_ptr_ext);
  assign full  = ((wr_ptr_ext[ADDR_WIDTH-1:0] == rd_ptr_ext[ADDR_WIDTH-1:0])) && 
                 ((wr_ptr_ext[ADDR_WIDTH] != rd_ptr_ext[ADDR_WIDTH]));

  // Memory block for buffer
  always_ff @(posedge clk) begin
    if (wr_en && !full) begin
      memory_block[wr_ptr_ext[ADDR_WIDTH-1:0]] <= din;
    end
  end

  // Output logic for Standard and FWFT modes
  generate
    if (FIFO_TYPE == "FWFT") begin
      always_comb begin
        if (rd_en) begin
          dout  = memory_block[rd_ptr_ext[ADDR_WIDTH-1:0]];
          valid = 1'd1;
        end
        else begin
          valid = 1'd0;
          dout  = memory_block[rd_ptr_ext[ADDR_WIDTH-1:0]];
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
            dout <= memory_block[rd_ptr_ext[ADDR_WIDTH-1:0]];
            valid <= 1'd1;
          end
          else begin
            valid <= 1'd0;
          end
        end
      end
    end
    else begin
      $fatal("Invalid FIFO type specified. Fatal error occurred!");
    end
  endgenerate

endmodule : sync_fifo