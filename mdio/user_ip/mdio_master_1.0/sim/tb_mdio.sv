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

module tb_mdio ();


  logic          clk       ;
  logic          rst_n     ;
  logic [ 5-1:0] phy_addr  ;
  logic [ 5-1:0] reg_addr  ;
  logic [16-1:0] data_in   ;
  logic          start     ;
  logic          write_en  ;
  logic          mdio_gem_t;
  logic          mdio_gem_o;
  logic          mdio_gem_i;
  logic          busy      ;

  initial begin
    clk      = 1'd0;
    rst_n    = 1'd1;
    start    = 1'd0;
    write_en = 1'd0;
    phy_addr = 5'd0;
    reg_addr = 5'd0;
    data_in  = 16'd0;
    repeat(10) @ (posedge clk);
    rst_n   = 1'd0;
    repeat(10) @ (posedge clk);
    rst_n   = 1'd1;
    repeat(10) @ (posedge clk);
    start    = 1'd1;
    write_en = 1'd1;
    phy_addr = 5'd5;
    reg_addr = 5'd10;
    data_in  = 16'hAAAA;
    repeat(1) @ (posedge clk);
    start    = 1'd0;
    // write_en = 1'd0;
    // phy_addr = 5'd0;
    // reg_addr = 5'd0;
    // data_in  = 16'd0;
    repeat(100) @ (posedge clk);
    $finish;
  end


  always begin
    #200 clk <= !clk;
  end

  mdio_master u_mdio_master (
    .clk       (clk       ), // 2.5Mhz clock
    .rst_n     (rst_n     ),
    .phy_addr  (phy_addr  ), // PHY address (5 bits)
    .reg_addr  (reg_addr  ), // Register address (5 bits)
    .data_in   (data_in   ), // Data to be written to PHY (for write ops)
    .start     (start     ), // Start MDIO transaction (1 = start, 0 = idle) -> single cycle pulse
    .write_en  (write_en  ), // Write enable (1 = write, 0 = read)
    .mdio_gem_t(mdio_gem_t), // Tri-state control (1 = read, 0 = write)
    .mdio_gem_o(mdio_gem_o), // MDIO output to PHY
    .mdio_gem_i(mdio_gem_i), // MDIO input from PHY
    .busy      (busy      )  // Busy signal (1 = in transaction)
  );

endmodule : tb_mdio
