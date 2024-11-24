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

module tb_slave_axil ();

  import axi_vip_master_pkg::*;
  import axi_vip_pkg::*;
  //----------------------------------------------
  // Local parameter
  //----------------------------------------------
  localparam AXI_ADDRESS_WIDTH = 32; // [32:16] interconnect address width | [15:0] peripheral address width  
  typedef axi_vip_master_pkg::axi_vip_master_mst_t axi_mst_agent_t;
  localparam AXI_ADDR_W    = axi_vip_master_pkg::axi_vip_master_VIP_ADDR_WIDTH;
  localparam AXI_DATA_W    = axi_vip_master_pkg::axi_vip_master_VIP_DATA_WIDTH;
  localparam AXI_STRB_W    = AXI_DATA_W / 8                                   ;
  localparam AXI_BURST_W   = 2                                                ;
  localparam AXI_CACHE_W   = 4                                                ;
  localparam AXI_PROT_W    = 3                                                ;
  localparam AXI_REGION_W  = 4                                                ;
  localparam AXI_USER_W    = 4                                                ;
  localparam AXI_QOS_W     = 4                                                ;
  localparam AXI_LEN_W     = 8                                                ;
  localparam AXI_SIZE_W    = 3                                                ;
  localparam AXI_RESP_W    = 2                                                ;
  localparam AXI_BEATS_MAX = 2**AXI_LEN_W                                     ;

  //----------------------------------------------
  // wires and regs
  //----------------------------------------------
  bit                             AXI_ACLK   ;
  bit                             AXI_RESETN ;
  logic                           AXI_AWVALID;
  logic [(AXI_ADDRESS_WIDTH-1):0] AXI_AWADDR ;
  logic                           AXI_AWREADY;
  logic                           AXI_WVALID ;
  logic [                   31:0] AXI_WDATA  ;
  logic [                    3:0] AXI_WSTRB  ;
  logic                           AXI_WREADY ;
  logic                           AXI_BVALID ;
  logic [                    1:0] AXI_BRESP  ;
  logic                           AXI_BREADY ;
  logic                           AXI_ARVALID;
  logic [(AXI_ADDRESS_WIDTH-1):0] AXI_ARADDR ;
  logic                           AXI_ARREADY;
  logic                           AXI_RVALID ;
  logic [                    1:0] AXI_RRESP  ;
  logic [                   31:0] AXI_RDATA  ;
  logic                           AXI_RREADY ;
  // register interface signal
  logic            axi_rstn ;
  logic            axi_clk  ;
  logic            axi_wreq ;
  logic [(16-3):0] axi_waddr;
  logic [    31:0] axi_wdata;
  logic            axi_wack ;
  logic            axi_rreq ;
  logic [(16-3):0] axi_raddr;
  logic [    31:0] axi_rdata;
  logic            axi_rack ;
  logic axi_werr;
  logic axi_rerr;

  typedef logic [AXI_ADDR_W-1:0]   axi_addr_t;
  typedef logic [AXI_DATA_W-1:0]   axi_data_t;
  typedef logic [AXI_STRB_W-1:0]   axi_strb_t;
  typedef logic [AXI_LEN_W-1:0]    axi_len_t;
  typedef logic [AXI_CACHE_W-1:0]  axi_cache_t;
  typedef logic [AXI_PROT_W-1:0]   axi_prot_t;
  typedef logic [AXI_REGION_W-1:0] axi_region_t;
  typedef logic [AXI_QOS_W-1:0]    axi_qos_t;

  typedef enum logic [AXI_BURST_W-1:0] {
    AXI_BURST_FIXED = 2'b00,
    AXI_BURST_INCR  = 2'b01,
    AXI_BURST_WRAP  = 2'b10,
    AXI_BURST_RSVD  = 2'b11
  } axi_burst_t;

  typedef enum logic [AXI_RESP_W-1:0] {
    AXI_RESP_OKAY   = 2'b00,
    AXI_RESP_EXOKAY = 2'b01,
    AXI_RESP_SLVERR = 2'b10,
    AXI_RESP_DECERR = 2'b11
  } axi_resp_t;

  typedef enum logic [AXI_SIZE_W-1:0] {
    AXI_SIZE_1B   = 3'b000,
    AXI_SIZE_2B   = 3'b001,
    AXI_SIZE_4B   = 3'b010,
    AXI_SIZE_8B   = 3'b011,
    AXI_SIZE_16B  = 3'b100,
    AXI_SIZE_32B  = 3'b101,
    AXI_SIZE_64B  = 3'b110,
    AXI_SIZE_128B = 3'b111
  } axi_size_t;

  axi_addr_t   axi_awaddr      ;
  axi_len_t    axi_awlen       ;
  axi_size_t   axi_awsize      ;
  axi_burst_t  axi_awburst     ;
  logic        axi_awlock      ;
  axi_cache_t  axi_awcache     ;
  axi_prot_t   axi_awprot      ;
  axi_region_t axi_awregion    ;
  axi_qos_t    axi_awqos       ;
  logic        axi_awvalid     ;
  logic        axi_awready     ;
  axi_data_t   axi_wdata       ;
  axi_strb_t   axi_wstrb       ;
  logic        axi_wlast       ;
  logic        axi_wvalid      ;
  logic        axi_wready      ;
  axi_resp_t   axi_bresp       ;
  logic        axi_bvalid      ;
  logic        axi_bready      ;
  axi_addr_t   axi_araddr      ;
  axi_len_t    axi_arlen       ;
  axi_size_t   axi_arsize      ;
  axi_burst_t  axi_arburst     ;
  logic        axi_arlock      ;
  axi_cache_t  axi_arcache     ;
  axi_prot_t   axi_arprot      ;
  axi_region_t axi_arregion    ;
  axi_qos_t    axi_arqos       ;
  logic        axi_arvalid     ;
  logic        axi_arready     ;
  axi_data_t   axi_rdata       ;
  axi_resp_t   axi_rresp       ;
  logic        axi_rlast    = 1;
  logic        axi_rvalid      ;
  logic        axi_rready      ;
  int mismatch_cnt0;
  int mismatch_cnt1;
  //---------------
  // Implementation
  //---------------

  always #10 AXI_ACLK = ~AXI_ACLK;

  initial begin
    AXI_RESETN = 1'b0;
    repeat (20) @(negedge AXI_ACLK);
    AXI_RESETN = 1'b1;
  end


  //----------------
  // AXI VIP Master
  //----------------
  axi_vip_master axi_mst (
    .aclk          (AXI_ACLK                          ),
    .aresetn       (AXI_RESETN                        ),
    .m_axi_awaddr  (AXI_AWADDR                        ),
    .m_axi_awlen   (axi_awlen                         ),
    .m_axi_awsize  (axi_awsize[0+:$bits(axi_awsize)]  ),
    .m_axi_awburst (axi_awburst[0+:$bits(axi_awburst)]),
    .m_axi_awlock  (axi_awlock                        ),
    .m_axi_awcache (axi_awcache                       ),
    .m_axi_awprot  (axi_awprot                        ),
    .m_axi_awregion(axi_awregion                      ),
    .m_axi_awqos   (axi_awqos                         ),
    .m_axi_awvalid (AXI_AWVALID                       ),
    .m_axi_awready (AXI_AWREADY                       ),
    .m_axi_wdata   (AXI_WDATA                         ),
    .m_axi_wstrb   (AXI_WSTRB                         ),
    .m_axi_wlast   (axi_wlast                         ),
    .m_axi_wvalid  (AXI_WVALID                        ),
    .m_axi_wready  (AXI_WREADY                        ),
    .m_axi_bresp   (AXI_BRESP                         ),
    .m_axi_bvalid  (AXI_BVALID                        ),
    .m_axi_bready  (AXI_BREADY                        ),
    .m_axi_araddr  (AXI_ARADDR                        ),
    .m_axi_arlen   (axi_arlen                         ),
    .m_axi_arsize  (axi_arsize[0+:$bits(axi_arsize)]  ),
    .m_axi_arburst (axi_arburst[0+:$bits(axi_arburst)]),
    .m_axi_arlock  (axi_arlock                        ),
    .m_axi_arcache (axi_arcache                       ),
    .m_axi_arprot  (axi_arprot                        ),
    .m_axi_arregion(axi_arregion                      ),
    .m_axi_arqos   (axi_arqos                         ),
    .m_axi_arvalid (AXI_ARVALID                       ),
    .m_axi_arready (AXI_ARREADY                       ),
    .m_axi_rdata   (AXI_RDATA                         ),
    .m_axi_rresp   (AXI_RRESP                         ),
    .m_axi_rlast   (axi_rlast                         ),
    .m_axi_rvalid  (AXI_RVALID                        ),
    .m_axi_rready  (AXI_RREADY                        )
  );

  axi_mst_agent_t axi_mst_agent;

  initial begin
    axi_mst_agent = new("axi_mst_agent", axi_mst.inst.IF);
    axi_mst_agent.start_master();
  end
  reg [2:0] prot = 3'b000; // No protection

  initial begin
    axi_data_t axi_wdata0 [];
    axi_addr_t axi_awaddr0[];
    axi_data_t axi_rdata0 [];
    axi_addr_t axi_araddr0[];
    logic [2-1:0]resp0;

    axi_data_t axi_wdata1 [];
    axi_addr_t axi_awaddr1[];
    axi_data_t axi_rdata1 [];
    axi_addr_t axi_araddr1[];
    logic [2-1:0]resp1;

    axi_wdata0  = new[5];
    axi_awaddr0 = new[5];
    axi_rdata0  = new[5];
    axi_araddr0 = new[5];

    axi_wdata1  = new[4];
    axi_awaddr1 = new[4];
    axi_rdata1  = new[4];
    axi_araddr1 = new[4];

    axi_wdata0  = {32'hdeadbeef, 32'hc0decafe, 32'hbabeb00b, 32'hcacadada, 32'hdeaddead};
    axi_awaddr0 = {32'h40000000, 32'h40000004, 32'h40000008, 32'h4000000C, 32'h40000010};
    axi_araddr0 = {32'h40000000, 32'h40000004, 32'h40000008, 32'h4000000C};

    axi_wdata1  = {32'hdeadbeef, 32'hc0decafe, 32'hbabeb00b, 32'hcacadada};
    axi_awaddr1 = {32'h40002200, 32'h40002204, 32'h40002208, 32'h4000220C};
    axi_araddr1 = {32'h40002200, 32'h40002204, 32'h40002208, 32'h4000220C};



    // Perform AXI transactions
    // Write transaction
    $display("Performing AXI write transaction...");
    for (int i = 0; i < 5; i++) begin
      axi_mst_agent.AXI4LITE_WRITE_BURST(axi_awaddr0[i], prot, axi_wdata0[i], resp0);
      repeat(5) @ (posedge AXI_ACLK);
    end
    
    for (int i = 0; i < 4; i++) begin
      axi_mst_agent.AXI4LITE_WRITE_BURST(axi_awaddr1[i], prot, axi_wdata1[i], resp1);
      repeat(5) @ (posedge AXI_ACLK);
    end

    // Read transaction
    $display("Performing AXI read transaction...");
    for (int i = 0; i < 4; i++) begin
      axi_mst_agent.AXI4LITE_READ_BURST(axi_araddr0[i], prot, axi_rdata0[i], resp0);
      repeat(5) @ (posedge AXI_ACLK);
      axi_mst_agent.AXI4LITE_READ_BURST(axi_araddr1[i], prot, axi_rdata1[i], resp1);
      repeat(5) @ (posedge AXI_ACLK);
    end
    #20;

    // Check if read data matches expected value
    for (int i = 0; i < 4; i++) begin
      if (axi_rdata0[i] == axi_wdata0[i]) begin
        $display("Read data matches expected value: %h", axi_rdata0[i]);
      end
      else begin
        mismatch_cnt0 = mismatch_cnt0 + 1;
        $display("Read data does not match expected value!");
      end
    end

    for (int i = 0; i < 4; i++) begin
      if (axi_rdata1[i] == axi_wdata1[i]) begin
        $display("Read data matches expected value: %h", axi_rdata1[i]);
      end
      else begin
        mismatch_cnt1 ++;
        $display("Read data does not match expected value!");
      end
    end

    if ((mismatch_cnt0 != 0) || (mismatch_cnt1 != 0)) begin
      $display("Test failed!");
    end
    else begin 
      $display("Test passed!");
    end

    repeat(100) @ (posedge AXI_ACLK);

    $finish;
  end



  //----------------
  // AXI Slave
  //----------------


  axilite_slave #(.AXI_ADDRESS_WIDTH(AXI_ADDRESS_WIDTH)) u_axilite_slave (
    // reset and clocks
    .AXI_RESETN (AXI_RESETN ),
    .AXI_ACLK   (AXI_ACLK   ),
    // axi4 interface
    .AXI_AWVALID(AXI_AWVALID),
    .AXI_AWADDR (AXI_AWADDR ),
    .AXI_AWREADY(AXI_AWREADY),
    .AXI_WVALID (AXI_WVALID ),
    .AXI_WDATA  (AXI_WDATA  ),
    .AXI_WSTRB  (AXI_WSTRB  ),
    .AXI_WREADY (AXI_WREADY ),
    .AXI_BVALID (AXI_BVALID ),
    .AXI_BRESP  (AXI_BRESP  ),
    .AXI_BREADY (AXI_BREADY ),
    .AXI_ARVALID(AXI_ARVALID),
    .AXI_ARADDR (AXI_ARADDR ),
    .AXI_ARREADY(AXI_ARREADY),
    .AXI_RVALID (AXI_RVALID ),
    .AXI_RRESP  (AXI_RRESP  ),
    .AXI_RDATA  (AXI_RDATA  ),
    .AXI_RREADY (AXI_RREADY ),
    // register interface can be used my multiple sub-peripherals
    .axi_rstn   (axi_rstn   ),
    .axi_clk    (axi_clk    ),
    .axi_wreq   (axi_wreq   ),
    .axi_waddr  (axi_waddr  ),
    .axi_wdata  (axi_wdata  ),
    .axi_werr   (axi_werr   ),
    .axi_wack   (axi_wack   ),
    .axi_rreq   (axi_rreq   ),
    .axi_raddr  (axi_raddr  ),
    .axi_rdata  (axi_rdata  ),
    .axi_rerr   (axi_rerr   ),
    .axi_rack   (axi_rack   )
  );

  logic          axi_werr_peripheral0 ;
  logic          axi_wack_peripheral0 ;
  logic          axi_rerr_peripheral0 ;
  logic          axi_rack_peripheral0 ;
  logic [32-1:0] axi_rdata_peripheral0;

  logic          axi_werr_peripheral1 ;
  logic          axi_wack_peripheral1 ;
  logic          axi_rerr_peripheral1 ;
  logic          axi_rack_peripheral1 ;
  logic [32-1:0] axi_rdata_peripheral1;

  logic [32-1:0] slave_peripheral0_reg0;
  logic [32-1:0] slave_peripheral0_reg1;
  logic [32-1:0] slave_peripheral0_reg2;
  logic [32-1:0] slave_peripheral0_reg3;

  logic [32-1:0] slave_peripheral1_reg0;
  logic [32-1:0] slave_peripheral1_reg1;
  logic [32-1:0] slave_peripheral1_reg2;
  logic [32-1:0] slave_peripheral1_reg3;

  always @(posedge axi_clk or negedge axi_rstn) begin
    if (!axi_rstn) begin
      axi_wack  <= 1'd0;
      axi_rack  <= 1'd0;
      axi_rdata <= 32'd0;
    end else begin
      axi_werr  <= axi_werr_peripheral0  | axi_werr_peripheral1 ;
      axi_wack  <= axi_wack_peripheral0  | axi_wack_peripheral1 ;
      axi_rerr  <= axi_rerr_peripheral0  | axi_rerr_peripheral1 ;
      axi_rack  <= axi_rack_peripheral0  | axi_rack_peripheral1 ;
      axi_rdata <= axi_rdata_peripheral0 | axi_rdata_peripheral1;
    end
  end

  register_interface #(.BASE_ADDRESS(7'h00)) u_sub_peripheral_0 (
    .axi_rstn  (axi_rstn              ),
    .axi_clk   (axi_clk               ),
    .axi_wreq  (axi_wreq              ),
    .axi_waddr (axi_waddr             ),
    .axi_wdata (axi_wdata             ),
    .axi_werr  (axi_werr_peripheral0  ),
    .axi_wack  (axi_wack_peripheral0  ),
    .axi_rreq  (axi_rreq              ),
    .axi_raddr (axi_raddr             ),
    .axi_rdata (axi_rdata_peripheral0 ),
    .axi_rerr  (axi_rerr_peripheral0  ),
    .axi_rack  (axi_rack_peripheral0  ),
    // Register
    .slave_reg0(slave_peripheral0_reg0),
    .slave_reg1(slave_peripheral0_reg1),
    .slave_reg2(slave_peripheral0_reg2),
    .slave_reg3(slave_peripheral0_reg3)
  );

  register_interface #(.BASE_ADDRESS(7'h11)) u_sub_peripheral_1 (
    .axi_rstn  (axi_rstn              ),
    .axi_clk   (axi_clk               ),
    .axi_wreq  (axi_wreq              ),
    .axi_waddr (axi_waddr             ),
    .axi_wdata (axi_wdata             ),
    .axi_werr  (axi_werr_peripheral1  ),
    .axi_wack  (axi_wack_peripheral1  ),
    .axi_rreq  (axi_rreq              ),
    .axi_raddr (axi_raddr             ),
    .axi_rdata (axi_rdata_peripheral1 ),
    .axi_rerr  (axi_rerr_peripheral1  ),
    .axi_rack  (axi_rack_peripheral1  ),
    // Register
    .slave_reg0(slave_peripheral1_reg0),
    .slave_reg1(slave_peripheral1_reg1),
    .slave_reg2(slave_peripheral1_reg2),
    .slave_reg3(slave_peripheral1_reg3)
  );

endmodule : tb_slave_axil


