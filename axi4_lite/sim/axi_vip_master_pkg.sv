///////////////////////////////////////////////////////////////////////////
//NOTE: This file has been automatically generated by Vivado.
///////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps
package axi_vip_master_pkg;
import axi_vip_pkg::*;
///////////////////////////////////////////////////////////////////////////
// These parameters are named after the component for use in your verification 
// environment.
///////////////////////////////////////////////////////////////////////////
      parameter axi_vip_master_VIP_PROTOCOL           = 0;
      parameter axi_vip_master_VIP_READ_WRITE_MODE    = "READ_WRITE";
      parameter axi_vip_master_VIP_INTERFACE_MODE     = 0;
      parameter axi_vip_master_VIP_ADDR_WIDTH         = 32;
      parameter axi_vip_master_VIP_DATA_WIDTH         = 32;
      parameter axi_vip_master_VIP_ID_WIDTH           = 0;
      parameter axi_vip_master_VIP_AWUSER_WIDTH       = 0;
      parameter axi_vip_master_VIP_ARUSER_WIDTH       = 0;
      parameter axi_vip_master_VIP_RUSER_WIDTH        = 0;
      parameter axi_vip_master_VIP_WUSER_WIDTH        = 0;
      parameter axi_vip_master_VIP_BUSER_WIDTH        = 0;
      parameter axi_vip_master_VIP_SUPPORTS_NARROW    = 0;
      parameter axi_vip_master_VIP_HAS_BURST          = 0;
      parameter axi_vip_master_VIP_HAS_LOCK           = 0;
      parameter axi_vip_master_VIP_HAS_CACHE          = 0;
      parameter axi_vip_master_VIP_HAS_REGION         = 0;
      parameter axi_vip_master_VIP_HAS_QOS            = 0;
      parameter axi_vip_master_VIP_HAS_PROT           = 1;
      parameter axi_vip_master_VIP_HAS_WSTRB          = 1;
      parameter axi_vip_master_VIP_HAS_BRESP          = 1;
      parameter axi_vip_master_VIP_HAS_RRESP          = 1;
      parameter axi_vip_master_VIP_HAS_ACLKEN         = 0;
      parameter axi_vip_master_VIP_HAS_ARESETN        = 1;
///////////////////////////////////////////////////////////////////////////
typedef axi_mst_agent #(axi_vip_master_VIP_PROTOCOL, 
                        axi_vip_master_VIP_ADDR_WIDTH,
                        axi_vip_master_VIP_DATA_WIDTH,
                        axi_vip_master_VIP_DATA_WIDTH,
                        axi_vip_master_VIP_ID_WIDTH,
                        axi_vip_master_VIP_ID_WIDTH,
                        axi_vip_master_VIP_AWUSER_WIDTH, 
                        axi_vip_master_VIP_WUSER_WIDTH, 
                        axi_vip_master_VIP_BUSER_WIDTH, 
                        axi_vip_master_VIP_ARUSER_WIDTH,
                        axi_vip_master_VIP_RUSER_WIDTH, 
                        axi_vip_master_VIP_SUPPORTS_NARROW, 
                        axi_vip_master_VIP_HAS_BURST,
                        axi_vip_master_VIP_HAS_LOCK,
                        axi_vip_master_VIP_HAS_CACHE,
                        axi_vip_master_VIP_HAS_REGION,
                        axi_vip_master_VIP_HAS_PROT,
                        axi_vip_master_VIP_HAS_QOS,
                        axi_vip_master_VIP_HAS_WSTRB,
                        axi_vip_master_VIP_HAS_BRESP,
                        axi_vip_master_VIP_HAS_RRESP,
                        axi_vip_master_VIP_HAS_ARESETN) axi_vip_master_mst_t;
      
///////////////////////////////////////////////////////////////////////////
// How to start the verification component
///////////////////////////////////////////////////////////////////////////
//      axi_vip_master_mst_t  axi_vip_master_mst;
//      initial begin : START_axi_vip_master_MASTER
//        axi_vip_master_mst = new("axi_vip_master_mst", `axi_vip_master_PATH_TO_INTERFACE);
//        axi_vip_master_mst.start_master();
//      end



endpackage : axi_vip_master_pkg
