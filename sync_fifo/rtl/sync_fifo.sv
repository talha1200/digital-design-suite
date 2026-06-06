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
  output logic                  overflow ,
  output logic                  underflow,
  output logic                  valid,
  output logic [DATA_WIDTH-1:0] dout
);

  //---------------------------
  // Localparam
  //---------------------------
  localparam ADDR_WIDTH  = (FIFO_DEPTH <= 1) ? 1 : $clog2(FIFO_DEPTH);
  localparam COUNT_WIDTH = $clog2(FIFO_DEPTH + 1);
  localparam logic [COUNT_WIDTH-1:0] FIFO_DEPTH_COUNT = COUNT_WIDTH'(FIFO_DEPTH);
  localparam logic [ADDR_WIDTH-1:0] FIFO_PTR_LAST = ADDR_WIDTH'(FIFO_DEPTH - 1);

  //---------------------------
  // Internal wires and regs
  //---------------------------
  logic [ADDR_WIDTH-1:0] wr_ptr;
  logic [ADDR_WIDTH-1:0] rd_ptr;
  logic [COUNT_WIDTH-1:0] fifo_count;
  logic [DATA_WIDTH-1:0] memory_block[FIFO_DEPTH-1:0];
  logic write_fire;
  logic read_fire;

  // ---------------------------------
  // Implementation
  // ---------------------------------

  generate
    if (SIMULATION) begin : gen_sim_init
      initial begin
        for (int i = 0; i < FIFO_DEPTH; i++) begin
          memory_block[i] = {DATA_WIDTH{1'd0}};
        end
      end
    end
  endgenerate

  assign empty = (fifo_count == '0);
  assign full  = (fifo_count == FIFO_DEPTH_COUNT);

  assign read_fire  = rd_en && !empty;
  assign write_fire = wr_en && (!full || read_fire);

  // Write pointer increments with every accepted write.
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr <= '0;
    end
    else if (write_fire) begin
      wr_ptr <= (wr_ptr == FIFO_PTR_LAST) ? '0 : wr_ptr + 1'b1;
    end
  end

  // Read pointer increments with every accepted read.
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rd_ptr <= '0;
    end
    else if (read_fire) begin
      rd_ptr <= (rd_ptr == FIFO_PTR_LAST) ? '0 : rd_ptr + 1'b1;
    end
  end

  // Occupancy count drives the full and empty flags exactly for any FIFO_DEPTH.
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      fifo_count <= '0;
    end
    else begin
      case ({write_fire, read_fire})
        2'b10: fifo_count <= fifo_count + 1'b1;
        2'b01: fifo_count <= fifo_count - 1'b1;
        default: fifo_count <= fifo_count;
      endcase
    end
  end

  // One-cycle status pulses for rejected accesses.
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      overflow  <= 1'b0;
      underflow <= 1'b0;
    end
    else begin
      overflow  <= wr_en && full && !read_fire;
      underflow <= rd_en && empty;
    end
  end

  // Memory block for buffer
  always_ff @(posedge clk) begin
    if (write_fire) begin
      memory_block[wr_ptr] <= din;
    end
  end

  // Output logic for Standard and FWFT modes
  generate
    if (FIFO_TYPE == "FWFT") begin : gen_fwft
      always_comb begin
        valid = !empty;
        dout  = empty ? {DATA_WIDTH{1'd0}} : memory_block[rd_ptr];
      end
    end
    else if (FIFO_TYPE == "Standard") begin : gen_standard
      always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
          dout  <= {DATA_WIDTH{1'd0}};
          valid <= 1'd0;
        end
        else begin
          if (read_fire) begin
            dout <= memory_block[rd_ptr];
            valid <= 1'd1;
          end
          else begin
            valid <= 1'd0;
          end
        end
      end
    end
    else begin : gen_invalid_fifo_type
      initial begin
        $fatal("Invalid FIFO type specified. Fatal error occurred!");
      end
    end
  endgenerate

endmodule : sync_fifo
