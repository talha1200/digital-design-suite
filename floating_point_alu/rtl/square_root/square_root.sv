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

module square_root #(
  parameter SIZE          = 8'd64 , //Orignal Size of Double Precision Floating point
  parameter EXPONENT_SIZE = 4'd11 , //Exponent Size in Double Precision Floating point
  parameter BINARY_SIZE   = 8'd106, //Size of 52x52 Multiplication
  parameter MANTISSA_SIZE = 8'd52 , //Mantissa Size in Double Precision Floating point
  parameter ODD           = 11'd52, //Size of ODD exponent in Double Precision Floating point
  parameter EVEN          = 11'd53  //Size of EVEN exponent in Double Precision Floating point
) (
  input  logic          Clock     , //Clock to the System
  input  logic [   2:0] fpalu_mode,
  input  logic [64-1:0] operand_a ,
  output logic [64-1:0] result_sqr
);

  //------------------
  // internal signals
  //------------------

  logic                     SIGN                  ; //Sign Part
  logic [EXPONENT_SIZE-1:0] EXPONENT              ; //Exponent Part
  logic [EXPONENT_SIZE-1:0] NormalisedExponent    ; //Normalized Exponent
  logic [MANTISSA_SIZE-1:0] MANTISSA              ; //Mantissa Part
  logic                     DONE_FLAGE            ; //Done Flage used to check the completion od SQRT
  logic                     Normalized            ; //Normalized Component
  logic [         SIZE-1:0] Exceptional_Output    ; //Exceptional output for cased like NaN and infinity
  logic [MANTISSA_SIZE-1:0] SQRT_MANTISSA         ; //Square root of mantissa
  logic [  BINARY_SIZE-1:0] BINARYMANTISSA        ; //Binary value of Mantissa
  logic [  BINARY_SIZE-1:0] BINARYMANTISSAREGISTER;
  logic [EXPONENT_SIZE-1:0] EXPONENTREGISTER      ;
  logic [MANTISSA_SIZE-1:0] MANTISSAREGISTER      ;
  logic                     SIGNREGISTER          ;
  logic                     ODDEXPONENT           ; //Checking odd exponent


  typedef enum logic [3:0] {
    TAKE_OPERAND,
    UNUSUAL_CASES,
    SQRT0,
    SQRT1,
    RESULT} state_t;

  state_t state;

  always_ff @ (posedge Clock) begin
    case (state)
      TAKE_OPERAND : begin
        EXPONENTREGISTER <= EXPONENT;
        MANTISSAREGISTER <= MANTISSA;
        SIGNREGISTER     <= SIGN;
        state            <= UNUSUAL_CASES;
      end

      UNUSUAL_CASES : begin
        if (Normalized) begin
          ODDEXPONENT <= EXPONENTREGISTER & 1;
          state       <= SQRT0;
        end
        else begin
          result_sqr <= Exceptional_Output;
          state      <= RESULT;
        end
      end

      SQRT0 : begin
        EXPONENTREGISTER       <= NormalisedExponent;
        BINARYMANTISSAREGISTER <= BINARYMANTISSA;
        state                  <= SQRT1;
      end

      SQRT1 : begin
        if (DONE_FLAGE) begin
          MANTISSAREGISTER <= SQRT_MANTISSA;
          state            <= RESULT;
        end
        else begin
          state <= SQRT1;
        end
      end

      RESULT : begin
        if(fpalu_mode == 3'b100) begin
          result_sqr <= {SIGNREGISTER, EXPONENTREGISTER, MANTISSAREGISTER};
          state      <= TAKE_OPERAND;
        end
        else begin
          result_sqr <= 64'd0;
        end
      end

      default : state <= TAKE_OPERAND;
    endcase
  end

  //Taking Sign, Exponent and Mantissa on Every clock edge
  always_ff @(Clock) begin
    SIGN     <= operand_a[63];
    EXPONENT <= operand_a[63:52];
    MANTISSA <= operand_a[51:0] ;
  end

  //Normalizing the Exponent Part of the input Number
  always_ff @(Clock) begin
    if ((EXPONENTREGISTER & 1)) begin
      NormalisedExponent <= (((EXPONENTREGISTER - 11'd1075 - ODD) >> 1) + 11'd1075);
    end
    else begin
      NormalisedExponent <= (((EXPONENTREGISTER - 1075 - EVEN) >> 1) + 11'd1075);
    end
  end

  always_ff @(Clock) begin
    if (EXPONENTREGISTER & 1) begin
      BINARYMANTISSA = {1'b0, 1'b1, MANTISSA[51:0], 52'b0};
    end
    else begin
      BINARYMANTISSA = {1'b1, MANTISSA[51:0], 53'b0};
    end
  end

  // to the square root module
  square_root_mantissa u_square_root_mantissa (
    .operand_a (BINARYMANTISSAREGISTER),
    .MANTISSA  (SQRT_MANTISSA         ),
    .DONE_FLAGE(DONE_FLAGE            )
  );

  // to the exception handling module
  exceptional_cases u_exceptional_cases (
    .SIGN      (SIGNREGISTER      ),
    .EXPONENT  (EXPONENTREGISTER  ),
    .MANTISSA  (MANTISSAREGISTER  ),
    .out       (Exceptional_Output),
    .Normalized(Normalized        )
  );

endmodule : square_root
