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
module axilite_slave #(
  parameter AXI_ADDRESS_WIDTH = 16,
  parameter VALID_ADDR_RANGE  = 16'h000F // only four registers
) (
  // reset and clocks
  input  logic                           AXI_RESETN ,
  input  logic                           AXI_ACLK   ,
  // axi4 interface
  input  logic                           AXI_AWVALID,
  input  logic [(AXI_ADDRESS_WIDTH-1):0] AXI_AWADDR ,
  output logic                           AXI_AWREADY,
  input  logic                           AXI_WVALID ,
  input  logic [                   31:0] AXI_WDATA  ,
  input  logic [                    3:0] AXI_WSTRB  ,
  output logic                           AXI_WREADY ,
  output logic                           AXI_BVALID ,
  output logic [                    1:0] AXI_BRESP  ,
  input  logic                           AXI_BREADY ,
  input  logic                           AXI_ARVALID,
  input  logic [(AXI_ADDRESS_WIDTH-1):0] AXI_ARADDR ,
  output logic                           AXI_ARREADY,
  output logic                           AXI_RVALID ,
  output logic [                    1:0] AXI_RRESP  ,
  output logic [                   31:0] AXI_RDATA  ,
  input  logic                           AXI_RREADY ,
  output logic                           axi_rstn   ,
  output logic                           axi_clk    ,
  output logic                           axi_wreq   ,
  output logic [(AXI_ADDRESS_WIDTH-3):0] axi_waddr  ,
  output logic [                   31:0] axi_wdata  ,
  input  logic                           axi_wack   ,
  output logic                           axi_rreq   ,
  output logic [(AXI_ADDRESS_WIDTH-3):0] axi_raddr  ,
  input  logic [                   31:0] axi_rdata  ,
  input  logic                           axi_rack
);

  //-------------------------------------
  // local parameters
  //-------------------------------------
  localparam AXI_DATA_WIDTH = 32;

  //-------------------------------------
  // Internal wire and regs
  //-------------------------------------

  typedef enum logic [1:0] {
    AXI_RESP_OKAY   = 2'b00,  // Normal, successful transaction
    AXI_RESP_EXOKAY = 2'b01,  // Exclusive access okay // multi-master access
    AXI_RESP_SLVERR = 2'b10,  // Slave error
    AXI_RESP_DECERR = 2'b11   // Decode error
  } axi_resp_t;

  logic                      wsel      ;
  logic [               4:0] wr_req_cnt;
  logic                      rack_d    ;
  logic [AXI_DATA_WIDTH-1:0] rdata_d   ;
  logic                      rsel      ;
  logic [               4:0] rd_req_cnt;
  logic                      aw_en     ;
  logic                      rack_s    ;

  //-------------------------------------
  // Implementation
  //-------------------------------------

  assign axi_rstn = AXI_RESETN;
  assign axi_clk  = AXI_ACLK;

  //----------------
  // write channel
  //----------------

  always_ff @(posedge AXI_ACLK or negedge AXI_RESETN) begin
    if (!AXI_RESETN) begin
      AXI_AWREADY <= 1'd0;
      AXI_WREADY  <= 1'd0;
    end
    else begin
      if (AXI_AWREADY == 1'b1) begin
        AXI_AWREADY <= 1'b0;
      end
      else if (aw_en == 1'b1) begin
        AXI_AWREADY <= 1'b1;
      end
      if (AXI_WREADY == 1'b1) begin
        AXI_WREADY <= 1'b0;
      end
      else if (aw_en == 1'b1) begin
        AXI_WREADY <= 1'b1;
      end
    end
  end

  // write response logic
  always_ff @(posedge AXI_ACLK or negedge AXI_RESETN) begin
    if (!AXI_RESETN) begin
      AXI_BVALID <= 0;
      AXI_BRESP  <= AXI_RESP_OKAY;
    end
    else begin
      if (AXI_AWREADY && AXI_AWVALID && ~AXI_BVALID && AXI_WREADY && AXI_WVALID) begin
        AXI_BVALID <= 1'b1;
        AXI_BRESP  <= (AXI_AWADDR > VALID_ADDR_RANGE) ? AXI_RESP_DECERR : AXI_RESP_OKAY;
      end
      // else if (WRITE_PROTECTION) begin // when user attempt write operation to read only register
      //   AXI_BRESP <= AXI_RESP_SLVERR;
      // end
      else begin
        if (AXI_BREADY && AXI_BVALID) begin
          AXI_BVALID <= 1'b0;
        end
      end
    end
  end

  // axi-lite address latching
  always_ff @(posedge AXI_ACLK or negedge AXI_RESETN) begin
    if (!AXI_RESETN) begin
      axi_waddr <= {AXI_ADDRESS_WIDTH-3{1'd0}};
    end
    else begin
      if (AXI_AWVALID) begin
        axi_waddr <= AXI_AWADDR[(AXI_ADDRESS_WIDTH-1):2];
      end
    end
  end

  always_ff @(posedge AXI_ACLK or negedge AXI_RESETN) begin
    if (!AXI_RESETN) begin
      wsel      <= 1'd0;
      axi_wreq  <= 1'd0;
      axi_wdata <= {AXI_DATA_WIDTH{1'd0}};
    end
    else begin
      if (wsel == 1'b1) begin
        if ((AXI_BREADY == 1'b1) && (AXI_BVALID == 1'b1)) begin
          wsel <= 1'b0;
        end
        axi_wreq <= 1'b0;
      end
      else begin
        wsel      <= AXI_AWVALID & AXI_WVALID;
        axi_wreq  <= AXI_AWVALID & AXI_WVALID;
        axi_wdata <= AXI_WDATA;
      end
    end
  end

  // write counter logic used to control the timing of the write request
  always_ff @(posedge AXI_ACLK or negedge AXI_RESETN) begin
    if(!AXI_RESETN) begin
      wr_req_cnt <= 5'd0;
    end
    else begin
      if (aw_en) begin
        wr_req_cnt <= 5'h00;
      end
      else if (wr_req_cnt[4]) begin
        wr_req_cnt <= wr_req_cnt + 1'b1;
      end
      else if (axi_wreq) begin
        wr_req_cnt <= 5'h10;
      end
      else begin
        wr_req_cnt <= wr_req_cnt;
      end
    end
  end

  always_comb begin
    aw_en = 1'd0;
    if (wr_req_cnt == 5'd31) begin
      aw_en = 1'd1;
    end
    else begin
      aw_en = (wr_req_cnt[4] & axi_wack);
    end
  end

  //-------------------
  // read channel
  //-------------------


  always_ff @(posedge AXI_ACLK or negedge AXI_RESETN) begin
    if (!AXI_RESETN) begin
      AXI_RVALID <= 1'd0;
      AXI_RRESP  <= AXI_RESP_OKAY;
    end
    else begin
      if (AXI_ARREADY && AXI_ARVALID && ~AXI_RVALID) begin
        // Valid read data is available at the read data bus
        AXI_RVALID <= 1'b1;
        AXI_RRESP  <= (AXI_ARADDR > VALID_ADDR_RANGE) ? AXI_RESP_DECERR : AXI_RESP_OKAY;
      end
      else if (AXI_RVALID && AXI_RREADY) begin
        // Read data is accepted by the master
        AXI_RVALID <= 1'b0;
      end
    end
  end

  always_ff @(posedge AXI_ACLK or negedge AXI_RESETN) begin
    if (!AXI_RESETN) begin
      AXI_ARREADY <= 1'd0;
      AXI_RDATA   <= 32'd0;
    end
    else begin
      if (AXI_ARREADY == 1'b1) begin
        AXI_ARREADY <= 1'b0;
      end
      else if (rack_s == 1'b1) begin
        AXI_ARREADY <= 1'b1;
      end
      if ((AXI_RREADY == 1'b1) && (AXI_RVALID == 1'b1)) begin
        AXI_RDATA <= 32'd0;
      end
      else if (rack_d == 1'b1) begin
        AXI_RDATA <= rdata_d;
      end
    end
  end

  always_ff @(posedge AXI_ACLK or negedge AXI_RESETN) begin
    if (!AXI_RESETN) begin
      rack_d    <= 1'd0;
      rdata_d   <= 32'd0;
      rsel      <= 1'd0;
      axi_rreq  <= 1'd0;
      axi_raddr <= 32'd0;
    end
    else begin
      rack_d  <= rack_s;
      rdata_d <= axi_rdata;
      if (rsel == 1'b1) begin
        if ((AXI_RREADY == 1'b1) && (AXI_RVALID == 1'b1)) begin
          rsel <= 1'b0;
        end
        axi_rreq <= 1'b0;
      end
      else begin
        rsel      <= AXI_ARVALID;
        axi_rreq  <= AXI_ARVALID;
        axi_raddr <= AXI_ARADDR[(AXI_ADDRESS_WIDTH-1):2];
      end
    end
  end

  always_ff @(posedge AXI_ACLK or negedge AXI_RESETN) begin
    if(!AXI_RESETN) begin
      rd_req_cnt <= 0;
    end
    else begin
      if (rack_s == 1'b1) begin
        rd_req_cnt <= 5'h00;
      end
      else if (rd_req_cnt[4] == 1'b1) begin
        rd_req_cnt <= rd_req_cnt + 1'b1;
      end
      else if (axi_rreq == 1'b1) begin
        rd_req_cnt <= 5'h10;
      end
      else begin
        rd_req_cnt <= rd_req_cnt;
      end
    end
  end

  always_comb begin
    rack_s = 1'd0;
    if (rd_req_cnt == 5'd31) begin
      rack_s = 1'd1;
    end
    else begin
      rack_s = (rd_req_cnt[4] & axi_rack);
    end
  end


endmodule : axilite_slave
