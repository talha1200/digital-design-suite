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
  parameter BASE_ADDRESS = 7'h10
) (
  input  logic          axi_rstn  ,
  input  logic          axi_clk   ,
  input  logic          axi_wreq  ,
  input  logic [14-1:0] axi_waddr ,
  input  logic [32-1:0] axi_wdata ,
  output logic          axi_wack  ,
  input  logic          axi_rreq  ,
  input  logic [14-1:0] axi_raddr ,
  output logic [32-1:0] axi_rdata ,
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
  logic        is_read_req  ;

  //-------------------------------------
  // Implementation
  //-------------------------------------

  //----------------------
  // decode block select
  //----------------------

  assign is_write_req = (axi_waddr[13:7] == BASE_ADDRESS) ? axi_wreq : 1'b0;
  assign is_read_req = (axi_raddr[13:7] == BASE_ADDRESS) ? axi_rreq : 1'b0;

  //-----------------
  // write interface
  //-----------------


  always @(posedge axi_clk or negedge axi_rstn) begin
    if (!axi_rstn) begin
      axi_wack <= 1'd0;
    end
    else begin
      if ((is_write_req == 1'b1) && (axi_waddr[6:0] == 7'h00)) begin
        slave_reg0 <= axi_wdata;
        axi_wack <= is_write_req;
      end
      else if ((is_write_req == 1'b1) && (axi_waddr[6:0] == 7'h01)) begin
        slave_reg1 <= axi_wdata;
        axi_wack <= is_write_req;
      end
      else if ((is_write_req == 1'b1) && (axi_waddr[6:0] == 7'h02)) begin
        slave_reg2 <= axi_wdata;
        axi_wack <= is_write_req;
      end
      else if ((is_write_req == 1'b1) && (axi_waddr[6:0] == 7'h03)) begin
        slave_reg3 <= axi_wdata;
        axi_wack <= is_write_req;
      end
      // add more register here if needed
      else begin 
        axi_wack <= 1'd0; // no such register
      end
    end
  end

  //-----------------
  // read interface
  //-----------------

  always @(posedge axi_clk or negedge axi_rstn) begin
    if (!axi_rstn) begin
      axi_rack  <= 'd0;
      axi_rdata <= 'd0;
    end
    else begin
      axi_rack <= is_read_req;
      if (is_read_req == 1'b1) begin
        case (axi_raddr[6:0])
          7'h00   : axi_rdata <= slave_reg0;
          7'h01   : axi_rdata <= slave_reg1;
          7'h02   : axi_rdata <= slave_reg2;
          7'h03   : axi_rdata <= slave_reg3;
          // add more register here if needed
          default : axi_rdata <= 0;
        endcase
      end
      else begin
        axi_rdata <= 32'd0;
      end
    end
  end

endmodule
