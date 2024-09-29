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

module tb_master_mdio ();

  parameter XILINX_PHY_ADDR = 5'h08;
  parameter USER_PHY_ADDR   = 5'h01;

  logic clkin      ;
  logic rx_reset   ;
  logic tx_reset   ;
  logic GMII_tx_clk;
  logic RGMII_txc  ;

  logic          clk           ;
  logic          rst_n         ;
  logic [ 5-1:0] phy_addr      ;
  logic [ 5-1:0] reg_addr      ;
  logic [16-1:0] data_in       ;
  logic          start         ;
  logic          write_en      ;
  logic          busy          ;
  logic          data_out_valid;
  logic [16-1:0] data_out      ;

  // Task for write operation
  task mdio_write(input [4:0] t_phy_addr, input [4:0] t_reg_addr, input [15:0] t_data);
    begin
      start    = 1'b1;
      write_en = 1'b1;
      phy_addr = t_phy_addr;
      reg_addr = t_reg_addr;
      data_in  = t_data;
      repeat(2) @ (posedge clk);
      start    = 1'b0;
      wait(!busy);
    end
  endtask

  // Task for read operation
  task mdio_read(input [4:0] t_phy_addr, input [4:0] t_reg_addr);
    begin
      start    = 1'b1;
      write_en = 1'b0;
      phy_addr = t_phy_addr;
      reg_addr = t_reg_addr;
      repeat(2) @ (posedge clk);
      start    = 1'b0;
      wait(!busy);
    end
  endtask

  initial begin
    clkin    = 1'b0;
    rx_reset = 1'b1;
    tx_reset = 1'b1;
    repeat(10) @ (posedge clkin);
    rx_reset = 1'b0;
    tx_reset = 1'b0;
  end

  initial begin
    clk      = 1'h0;
    rst_n    = 1'h1;
    start    = 1'h0;
    write_en = 1'h0;
    phy_addr = 5'h0;
    reg_addr = 5'h0;
    data_in  = 16'h0;
    repeat(10) @ (posedge clk);
    rst_n   = 1'h0;
    repeat(10) @ (posedge clk);
    rst_n   = 1'h1;
    repeat(10) @ (posedge clk);
    wait(!busy);

    mdio_write (XILINX_PHY_ADDR, 5'h10, 16'h0140); // write to xilinx gmii-to-rgmii core
    mdio_read  (XILINX_PHY_ADDR, 5'h10); // read from xilinx gmii-to-rgmii core
    mdio_write (USER_PHY_ADDR  , 5'h01, 16'hAAAA); // write to user/external mdio slave core
    mdio_read  (XILINX_PHY_ADDR, 5'h11); // read from xilinx gmii-to-rgmii core
    mdio_read  (XILINX_PHY_ADDR, 5'h12); // read from xilinx gmii-to-rgmii core
    mdio_read  (USER_PHY_ADDR  , 5'h00); // read from user/external mdio slave core
    mdio_read  (USER_PHY_ADDR  , 5'h01); // read from user/external mdio slave core

    repeat(100) @ (posedge clk);
    $finish;
  end

  always begin
    #200 clk <= !clk;
  end

  always begin
    #2.5 clkin <= !clkin;
  end

  mdio_test_wrapper u_mdio_test_wrapper (
    // gmii-to-rgmii signals
    .GMII_col         (              ),
    .GMII_crs         (              ),
    .GMII_rx_clk      (GMII_tx_clk   ),
    .GMII_rx_dv       (              ),
    .GMII_rx_er       (              ),
    .GMII_rxd         (              ),
    .GMII_tx_clk      (GMII_tx_clk   ),
    .GMII_tx_en       (              ),
    .GMII_tx_er       (              ),
    .GMII_txd         (              ),
    .RGMII_rd         (              ),
    .RGMII_rx_ctl     (              ),
    .RGMII_rxc        (RGMII_txc     ),
    .RGMII_td         (              ),
    .RGMII_tx_ctl     (              ),
    .RGMII_txc        (RGMII_txc     ),
    .clkin            (clkin         ),
    .clock_speed      (              ),
    .duplex_status    (              ),
    .gmii_clk_125m_out(              ),
    .gmii_clk_25m_out (              ),
    .gmii_clk_2_5m_out(              ),
    .link_status      (              ),
    .mmcm_locked_out  (              ),
    .ref_clk_out      (              ),
    .speed_mode       (              ),
    .rx_reset         (rx_reset      ),
    .tx_reset         (tx_reset      ),
    // mdio-master signals
    .clk              (clk           ),
    .rst_n            (rst_n         ),
    .data_in          (data_in       ),
    .busy             (busy          ),
    .phy_addr         (phy_addr      ),
    .reg_addr         (reg_addr      ),
    .start            (start         ),
    .write_en         (write_en      ),
    .data_out_valid   (data_out_valid),
    .data_out         (data_out      )
  );

endmodule : tb_master_mdio

