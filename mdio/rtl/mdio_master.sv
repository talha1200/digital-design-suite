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

// ref document 'marvell-phys-transceivers-alaska-88e151x-datasheet.pdf'
// page 66 figure number 22 and 23

module mdio_master (
  input  logic          clk           , // 2.5Mhz clock
  input  logic          rst_n         ,
  // mdio bus
  output logic          mdio_mdc      ,
  output logic          mdio_t        , // Tri-state control (1 = read, 0 = write)
  output logic          mdio_o        , // MDIO output to PHY
  input  logic          mdio_i        , // MDIO input from PHY
  // configuration registers
  input  logic          write_en      , // Write enable (1 = write, 0 = read)
  input  logic [   4:0] phy_addr      , // PHY address (5 bits)
  input  logic [   4:0] reg_addr      , // Register address (5 bits)
  input  logic [  15:0] data_in       , // Data to be written to PHY (for write ops)
  input  logic          start         , // Start MDIO transaction (1 = start, 0 = idle) -> single cycle pulse
  output logic          busy          , // Busy signal (1 = in transaction)
  output logic          data_out_valid,
  output logic [16-1:0] data_out        // Data read from slave
);

  //----------------------------
  // local parameter
  //----------------------------
  localparam START_FRAME = 2'b01;
  localparam WRITE       = 2'b01; //-- write opcode
  localparam READ        = 2'b10; //-- read opcode
  localparam TA_WRITE    = 2'b10;
  localparam TA_READ     = 2'bz0;

  //----------------------------
  // internal wires & regs
  //----------------------------

  (* fsm_encoding = "one_hot" *)
  // Define the states for the FSM
  typedef enum logic [3:0] {
    IDLE          ,
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
  mdio_state_t state;

  // Internal counters and signals
  logic [32-1:0] shift_reg     ; // Shift register for transmitting/receiving MDIO frames
  logic [ 5-1:0] bit_cnt       ; // Bit counter
  logic          write_en_latch;

  //----------------------
  // implementation
  //----------------------

  assign mdio_mdc = clk;

  always_ff @(posedge clk) begin
    if(!rst_n) begin
      shift_reg <= 32'd0;
    end
    else begin
      if (start) begin
        shift_reg <= {START_FRAME,(write_en ? WRITE : READ),phy_addr,reg_addr,(write_en ? TA_WRITE : TA_READ),data_in};
      end
    end
  end

  always_ff @(posedge clk) begin
    if(!rst_n) begin
    end
    else begin
      if (start) begin
        write_en_latch <= write_en;
      end
    end
  end

  // FSM and control logic
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state   <= IDLE;
      bit_cnt <= 5'd31;
      busy    <= 1'b0;
    end
    else begin
      // State actions
      case (state)
        IDLE : begin
          if (start) begin
            busy    <= 1'b1;
            bit_cnt <= bit_cnt - 1;
            state   <= PREAMBLE;
          end
          else begin
            busy    <= 1'b0;
            bit_cnt <= 5'd31;
            state   <= IDLE;
          end
        end
        PREAMBLE : begin
          bit_cnt <= bit_cnt - 1;
          if (bit_cnt == 0) begin
            state <= START_OF_FRAME;
          end
        end
        START_OF_FRAME : begin
          bit_cnt <= bit_cnt - 1;
          if (bit_cnt == 30) begin
            state <= OPCODE;
          end
        end
        OPCODE : begin
          bit_cnt <= bit_cnt - 1;
          if (bit_cnt == 28) begin
            state <= PHY_ADDR_PHASE;
          end
        end
        PHY_ADDR_PHASE : begin
          bit_cnt <= bit_cnt - 1;
          if (bit_cnt == 23) begin
            state <= REG_ADDR_PHASE;
          end
        end
        REG_ADDR_PHASE : begin
          bit_cnt <= bit_cnt - 1;
          if (bit_cnt == 18) begin
            state <= TURNAROUND;
          end
        end
        TURNAROUND : begin
          bit_cnt <= bit_cnt - 1;
          if (bit_cnt == 16) begin
            state <= DATA_PHASE;
          end
        end
        DATA_PHASE : begin
          if (write_en_latch) begin
            bit_cnt <= bit_cnt - 1;
            if (bit_cnt == 0) begin
              state <= COMPLETE;
            end
          end
          else begin
            bit_cnt <= bit_cnt - 1;
            if (bit_cnt == 0) begin
              state <= COMPLETE;
            end
          end
        end
        COMPLETE : begin
          bit_cnt <= 5'd31;
          busy    <= 1'b0;
          state   <= IDLE;
        end
      endcase
    end
  end

  always_comb begin
    mdio_t = 1'b0;
    mdio_o = 1'b1;
    case (state)
      IDLE : begin
        mdio_o = 1'b1;
      end
      PREAMBLE : begin
        mdio_o = 1'b1;
      end
      TURNAROUND : begin
        mdio_o = shift_reg[bit_cnt];
        if (bit_cnt == 5'd17) begin
          mdio_t = (!write_en_latch) ? 1'b1 : 1'b0; // for read mode set bus a z for 1 clock cycle during turn-around
        end
        else begin
          mdio_t = 1'b0;
        end
      end
      DATA_PHASE : begin
        if (write_en_latch) begin
          mdio_t = 1'b0;
          mdio_o = shift_reg[bit_cnt]; // Drive data bits for write
        end
        else begin
          mdio_t = 1'b1; // set high impedance for read mode
          mdio_o = 1'b1; // idle state
        end
      end
      default : begin
        mdio_t = 1'b0;
        mdio_o = shift_reg[bit_cnt];
      end
    endcase
  end

  assign data_out_valid = (!write_en_latch) ? (state == COMPLETE) : 1'b0;
  
  always_ff @ (posedge clk) begin
    if (!rst_n) begin
      data_out <= 16'd0;
    end
    else begin
      if ((state == DATA_PHASE)) begin
        data_out <= (!write_en_latch) ? ({data_out[14:0],mdio_i}) : 16'd0;
      end
    end
  end


endmodule : mdio_master
