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

module register_interface #(
  // parameters
  parameter int VALID_ADDR_RANGE  = 7'h04, // total number of register
  parameter int BASE_ADDRESS      = 7'h10
) (
  input  logic          axi_rstn  ,
  input  logic          axi_clk   ,
  input  logic          axi_wreq  ,
  input  logic [14-1:0] axi_waddr ,
  input  logic [32-1:0] axi_wdata ,
  output logic          axi_werr  ,
  output logic          axi_wack  ,
  input  logic          axi_rreq  ,
  input  logic [14-1:0] axi_raddr ,
  output logic [32-1:0] axi_rdata ,
  output logic          axi_rerr  ,
  output logic          axi_rack  ,
  // Register
  output logic [32-1:0] slave_reg0,
  output logic [32-1:0] slave_reg1,
  output logic [32-1:0] slave_reg2,
  output logic [32-1:0] slave_reg3
);

  //-------------------------------------------
  // local parameter
  //-------------------------------------------

  //-------------------------------------------
  // internal signals
  //-------------------------------------------

  logic        is_write_req ;
  logic        axi_wack_0 ;
  logic        axi_wack_1 ;
  logic        is_read_req  ;
  logic        axi_rack_0 ;
  logic        axi_rack_1 ;

  //-------------------------------------
  // Implementation
  //-------------------------------------

  //----------------------
  // decode block select
  //----------------------

  assign is_write_req = (axi_waddr[13:7] == BASE_ADDRESS) ? axi_wreq : 1'b0;
  assign is_read_req  = (axi_raddr[13:7] == BASE_ADDRESS) ? axi_rreq : 1'b0;

  //-----------------
  // write interface
  //-----------------

  always @(posedge axi_clk or negedge axi_rstn) begin
    if (!axi_rstn) begin
      axi_wack_0 <= 1'd0;
    end
    else begin
      if (is_write_req) begin
        case (axi_waddr[6:0])
          7'h00: begin
            axi_wack_0 <= 1'b1;
            slave_reg0 <= axi_wdata;
          end
          7'h01: begin
            axi_wack_0 <= 1'b1;
            slave_reg1 <= axi_wdata;
          end
          7'h02: begin
            axi_wack_0 <= 1'b1;
            slave_reg2 <= axi_wdata;
          end
          7'h03: begin
            axi_wack_0 <= 1'b1;
            slave_reg3 <= axi_wdata;
          end 
          // add more register here if needed
          default: axi_wack_0 <= 1'd0; // no such register
        endcase
      end
      else begin
        axi_wack_0 <= 1'd0;
      end
    end
  end

  always @(posedge axi_clk or negedge axi_rstn) begin
    if (!axi_rstn) begin
      axi_werr   <= 1'd0;
      axi_wack_1 <= 1'd0;
    end
    else begin
      if (is_write_req) begin
        if (axi_waddr[6:0] > (VALID_ADDR_RANGE - 1)) begin
          axi_werr   <= 1'd1;
          axi_wack_1 <= 1'd1;
        end
      end
      else begin
        axi_werr   <= 1'd0;
        axi_wack_1 <= 1'd0;
      end
    end
  end

  assign axi_wack = axi_wack_0 | axi_wack_1;

  //-----------------
  // read interface
  //-----------------

  always @(posedge axi_clk or negedge axi_rstn) begin
    if (!axi_rstn) begin
      axi_rack_0  <= 1'd0;
      axi_rdata   <= 32'd0;
    end
    else begin
      if (is_read_req == 1'b1) begin
        case (axi_raddr[6:0])
          7'h00   : begin
            axi_rack_0 <= 1'b1;
            axi_rdata  <= slave_reg0;
          end
          7'h01   : begin
            axi_rack_0 <= 1'b1;
            axi_rdata <= slave_reg1;
          end
          7'h02   : begin
            axi_rack_0 <= 1'b1;
            axi_rdata <= slave_reg2;
          end
          7'h03   : begin
            axi_rack_0 <= 1'b1;
            axi_rdata  <= slave_reg3;
          end
          // add more register here if needed
          default : begin
            axi_rack_0 <= 1'b0;
            axi_rdata  <= 32'd0;
          end 
        endcase
      end
      else begin
        axi_rack_0 <= 1'd0;
        axi_rdata <= 32'd0;
      end
    end
  end

  always @(posedge axi_clk or negedge axi_rstn) begin
    if (!axi_rstn) begin
      axi_rerr   <= 1'd0;
      axi_rack_1 <= 1'd0;
    end
    else begin
      if (is_write_req) begin
        if (axi_raddr[6:0] > (VALID_ADDR_RANGE - 1)) begin
          axi_rerr   <= 1'd1;
          axi_rack_1 <= 1'd1;
        end
      end
      else begin
        axi_rerr   <= 1'd0;
        axi_rack_1 <= 1'd0;
      end
    end
  end

  assign axi_rack = axi_rack_0 | axi_rack_1;

endmodule : register_interface
