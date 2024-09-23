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

module Shifter (
  input  logic [54:0] Mantissa_UnNormalized,
  input  logic [10:0] Exponent_a           ,
  output logic [54:0] Mantissa_Normalized  ,
  output logic [10:0] Exponent_sub
);

  //In this Module we are checking for various possible Mantissa Cases
  //And Shifting Mantissa Accordingly
  //Max Shift is 54
  //Min Shift is 0
  logic [5:0] shift;

  always_comb begin
    casex (Mantissa_UnNormalized)
      55'b1_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized;
        shift               = 6'd0;
      end
      55'b1_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 1;
        shift               = 6'd1;
      end

      55'b1_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 2;
        shift               = 6'd2;
      end

      55'b1_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 3;
        shift               = 6'd3;
      end

      55'b1_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 4;
        shift               = 6'd4;
      end

      55'b1_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 5;
        shift               = 6'd5;
      end

      55'b1_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 6;
        shift               = 6'd6;
      end

      55'b1_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 7;
        shift               = 6'd7;
      end

      55'b1_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 8;
        shift               = 6'd8;
      end

      55'b1_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 9;
        shift               = 6'd9;
      end

      55'b1_0000_0000_001x_xxxx_xxxx_xxxx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 10;
        shift               = 6'd10;
      end

      55'b1_0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 11;
        shift               = 6'd11;
      end

      55'b1_0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 12;
        shift               = 6'd12;
      end

      55'b1_0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 13;
        shift               = 6'd13;
      end

      55'b1_0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 14;
        shift               = 6'd14;
      end

      55'b1_0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 15;
        shift               = 6'd15;
      end

      55'b1_0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 16;
        shift               = 6'd16;
      end

      55'b1_0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 17;
        shift               = 6'd17;
      end

      55'b1_0000_0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 18;
        shift               = 6'd18;
      end

      55'b1_0000_0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 19;
        shift               = 6'd19;
      end

      55'b1_0000_0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 20;
        shift               = 6'd20;
      end

      55'b1_0000_0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 21;
        shift               = 6'd21;
      end

      55'b1_0000_0000_0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 22;
        shift               = 6'd22;
      end

      55'b1_0000_0000_0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 23;
        shift               = 6'd23;
      end

      55'b1_0000_0000_0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 24;
        shift               = 6'd24;
      end
      55'b1_0000_0000_0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 25;
        shift               = 6'd25;
      end
      55'b1_0000_0000_0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 26;
        shift               = 6'd26;
      end
      55'b1_0000_0000_0000_0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 27;
        shift               = 6'd27;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 28;
        shift               = 6'd28;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 29;
        shift               = 6'd29;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 30;
        shift               = 6'd30;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 31;
        shift               = 6'd31;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 32;
        shift               = 6'd32;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 33;
        shift               = 6'd33;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 34;
        shift               = 6'd34;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 35;
        shift               = 6'd35;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 36;
        shift               = 6'd36;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 37;
        shift               = 6'd37;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 38;
        shift               = 6'd38;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0000_0000_001x_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 39;
        shift               = 6'd39;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_xxxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 40;
        shift               = 6'd40;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1xxx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 41;
        shift               = 6'd41;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_01xx_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 42;
        shift               = 6'd42;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_001x_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 43;
        shift               = 6'd43;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_xxxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 44;
        shift               = 6'd44;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1xxx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 45;
        shift               = 6'd45;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_01xx_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 46;
        shift               = 6'd46;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_001x_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 47;
        shift               = 6'd47;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_xxxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 48;
        shift               = 6'd48;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1xxx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 49;
        shift               = 6'd49;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_01xx_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 50;
        shift               = 6'd50;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_001x_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 51;
        shift               = 6'd51;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_xx : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 52;
        shift               = 6'd52;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1x : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 53;
        shift               = 6'd53;
      end
      55'b1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_01 : begin
        Mantissa_Normalized = Mantissa_UnNormalized << 54;
        shift               = 6'd54;
      end
      default : begin
        Mantissa_Normalized = (~Mantissa_UnNormalized) + 1'b1;
        shift               = 11'd0;
      end
    endcase
  end
  
  //Normalizing the Exponent
  assign Exponent_sub = Exponent_a - shift;

endmodule
