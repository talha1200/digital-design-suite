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
    parameter        DATA_WIDTH = 8,
    parameter        FIFO_DEPTH = 16,
    parameter string FIFO_TYPE  = "Standard"
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

  localparam MAX_TRANSACTIONS = 64;

  int                    wrptr;
  int                    rdptr;
  logic [DATA_WIDTH-1:0] sent_data [MAX_TRANSACTIONS-1:0];
  logic [DATA_WIDTH-1:0] data;
  logic [DATA_WIDTH-1:0] standard_expected;
  logic                  standard_valid;
  logic                  read_accepted;
  logic                  write_accepted;

  // ---------------------------------
  // Implementation
  // ---------------------------------

  assign read_accepted  = rd_en && !empty;
  assign write_accepted = wr_en && (!full || read_accepted);

  always_ff @(negedge clk or negedge rst_n) begin
    if (!rst_n) begin
      data <= {DATA_WIDTH{1'd0}};
    end
    else begin 
      data <= data + 1'b1;
    end
  end

  // Drive controls on the negative edge so they are stable at the DUT clock edge.
  always_ff @(negedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_en <= 0;
      din   <= {DATA_WIDTH{1'd0}};
    end
    else begin
      if (!full && enable) begin
        wr_en <= 1'b1;
        din   <= data;
      end 
      else begin
        wr_en <= 1'b0;
      end
    end
  end

  always_ff @(negedge clk or negedge rst_n) begin
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

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      wrptr             <= 0;
      rdptr             <= 0;
      standard_expected <= {DATA_WIDTH{1'd0}};
      standard_valid    <= 1'b0;
    end
    else begin
      if (write_accepted) begin
        sent_data[wrptr % MAX_TRANSACTIONS] <= din;
        wrptr <= wrptr + 1;
      end

      if (FIFO_TYPE == "FWFT") begin
        if (read_accepted) begin
          if (dout !== sent_data[rdptr % MAX_TRANSACTIONS]) begin
            $fatal(1, "ERROR: Mismatch at index %0d: expected %0h, got %0h",
                   rdptr, sent_data[rdptr % MAX_TRANSACTIONS], dout);
          end
          else begin
            $display("Match at index %0d: data %0h", rdptr, dout);
          end
          rdptr <= rdptr + 1;
        end
      end
      else begin
        if (standard_valid) begin
          if (dout !== standard_expected) begin
            $fatal(1, "ERROR: Mismatch at index %0d: expected %0h, got %0h",
                   rdptr - 1, standard_expected, dout);
          end
          else begin
            $display("Match at index %0d: data %0h", rdptr - 1, dout);
          end
        end

        standard_valid <= read_accepted;
        if (read_accepted) begin
          standard_expected <= sent_data[rdptr % MAX_TRANSACTIONS];
          rdptr <= rdptr + 1;
        end
      end
    end
  end

endmodule
