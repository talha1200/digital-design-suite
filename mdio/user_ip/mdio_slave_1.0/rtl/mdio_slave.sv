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

module mdio_slave #(
  parameter PHY_ADDR = 1       , // User-defined PHY address
  parameter SLAVE_ID = 16'hDEAD, // User-defined Slave ID
  parameter NUM_REG  = 4
) (
  input  logic                     rst_n    ,
  input  logic                     mdio_mdc , // MDC clock from the master
  input  logic                     mdio_o   , // MDIO master output - slave input
  input  logic                     mdio_t   , // MDIO tri-state control from the master
  output logic                     mdio_i   , // MDIO master input - slave output
  // Registers
  output logic [NUM_REG-1:0][15:0] slave_reg  = {NUM_REG*16{1'b0}} // Slave side Registers
);

  //--------------------
  // local parameter
  //--------------------
  localparam WRITE    = 2'b01; //-- write opcode
  localparam READ     = 2'b10; //-- read opcode
  localparam TA_WRITE = 2'b10;
  localparam TA_READ  = 2'bz0;

  //------------------
  // Internal signals
  //------------------
  (* fsm_encoding = "one_hot" *)
  // Define the states for the FSM
  typedef enum logic [3:0] {
    PREAMBLE      ,
    START_OF_FRAME,
    OPCODE        ,
    PHY_ADDR_PHASE,
    REG_ADDR_PHASE,
    TURNAROUND    ,
    DATA_PHASE    ,
    COMPLETE
  } mdio_state_t;

  (* fsm_encoding = "one_hot" *)
  mdio_state_t   state     ;
  logic [ 5-1:0] bit_cnt   ; // Bit counter
  logic          mdio_o_reg;
  logic          sof       ;
  logic [16-1:0] slave_data;

  typedef struct packed{
    logic [ 2-1:0] instruction_code;
    logic [ 5-1:0] phy_address     ;
    logic [ 5-1:0] register_address;
    logic [ 2-1:0] ta_code         ;
    logic [16-1:0] master_data     ;
  } mdio_data_t;

  mdio_data_t shift_reg;


  //---------------
  // implementation
  //---------------

  always_ff @(posedge mdio_mdc) begin
    if(!rst_n) begin
      mdio_o_reg <= 1'b0;
    end
    else begin
      mdio_o_reg <= mdio_o;
    end
  end

  assign sof = !mdio_o && mdio_o_reg;


  //-------------------
  // MDIO State Machine
  //-------------------

  // FSM and control logic
  always_ff @(posedge mdio_mdc or negedge rst_n) begin
    if (!rst_n) begin
      state     <= PREAMBLE;
      shift_reg <= 30'd0;
      bit_cnt   <= 5'd31;
    end
    else begin
      // State actions
      case (state)
        PREAMBLE : begin
          if (sof) begin
            bit_cnt <= bit_cnt - 1;
            state   <= START_OF_FRAME;
          end
          else begin
            bit_cnt <= 5'd31;
            state   <= PREAMBLE;
          end
        end
        START_OF_FRAME : begin
          bit_cnt <= bit_cnt - 1;
          if (bit_cnt == 30) begin
            state <= OPCODE;
          end
        end
        OPCODE : begin
          shift_reg[bit_cnt] <= mdio_o;
          bit_cnt            <= bit_cnt - 1;
          if (bit_cnt == 28) begin
            state <= PHY_ADDR_PHASE;
          end
        end
        PHY_ADDR_PHASE : begin
          shift_reg[bit_cnt] <= mdio_o;
          bit_cnt            <= bit_cnt - 1;
          if (bit_cnt == 23) begin
            state <= REG_ADDR_PHASE;
          end
        end
        REG_ADDR_PHASE : begin
          shift_reg[bit_cnt] <= mdio_o;
          bit_cnt            <= bit_cnt - 1;
          if (bit_cnt == 18) begin
            state <= TURNAROUND;
          end
        end
        TURNAROUND : begin
          shift_reg[bit_cnt] <= mdio_o;
          bit_cnt            <= bit_cnt - 1;
          if (bit_cnt == 16) begin
            state <= DATA_PHASE;
          end
        end
        DATA_PHASE : begin
          shift_reg[bit_cnt] <= mdio_o;
          bit_cnt            <= bit_cnt - 1;
          if (bit_cnt == 0) begin
            state <= COMPLETE;
          end
        end
        COMPLETE : begin
          shift_reg <= 30'd0;
          bit_cnt   <= 5'd31;
          state     <= PREAMBLE;
        end
      endcase
    end
  end

  assign slave_data = slave_reg[shift_reg.register_address];

  always_comb begin
    mdio_i = 1'b0;
    if (state == DATA_PHASE) begin
      if (shift_reg.phy_address == PHY_ADDR && (shift_reg.instruction_code == READ)) begin
        mdio_i = slave_data[bit_cnt];
      end
    end
  end

  //-----------
  // slave side registers
  //-----------


  always_ff @(posedge mdio_mdc) begin
    slave_reg[0] <= SLAVE_ID; // read-only register
    if (shift_reg.phy_address == PHY_ADDR && (shift_reg.instruction_code == WRITE) && (shift_reg.ta_code == TA_WRITE)) begin
      slave_reg[shift_reg.register_address] <= shift_reg.master_data;
    end
  end
  

endmodule : mdio_slave

