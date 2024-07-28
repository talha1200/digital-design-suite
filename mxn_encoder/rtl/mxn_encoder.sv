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


module mxn_encoder #(
  parameter DATA_WIDTH    = 4,
  parameter PRIORITY_TYPE = 0  // 1: -> MSB , 0: -> LSB
) (
  input  logic [        DATA_WIDTH-1:0] unencoded_data    ,
  output logic                          valid_out         ,
  output logic [$clog2(DATA_WIDTH)-1:0] encoded_data_out  
);


  //-----------------------------------
  // local parameter
  //-----------------------------------

  //-----------------------------------
  // wires and regs
  //-----------------------------------

  logic [        DATA_WIDTH-1:0] mask       ;
  logic [$clog2(DATA_WIDTH)-1:0] encoded_pos;

  //-------------------------------------
  // Implementation
  //-------------------------------------

  // Determine the priority mask
  generate
    genvar i;
    if (!PRIORITY_TYPE) begin
      for (i = 0; i < DATA_WIDTH; i = i + 1) begin : gen_priority_lsb
        if (i == 0) begin
          assign mask[i] = unencoded_data[i];
        end else begin
          assign mask[i] = unencoded_data[i] & ~|unencoded_data[i-1:0];
        end
      end
    end
    else begin
      for (i = 0; i < DATA_WIDTH; i = i + 1) begin : gen_priority_msb
        if (i == DATA_WIDTH-1) begin
          assign mask[i] = unencoded_data[i];
        end else begin
          assign mask[i] = unencoded_data[i] & ~|unencoded_data[DATA_WIDTH-1:i+1];
        end
      end
    end
  endgenerate

  // Encode the position of the highest priority bit
  function [$clog2(DATA_WIDTH)-1:0] encode;
    input [DATA_WIDTH-1:0] mask;
    integer j;
    begin
      encode = 0;
      for (j = 0; j < DATA_WIDTH; j = j + 1) begin
        if (mask[j]) begin
          encode = j;
        end
      end
    end
  endfunction

  always_comb begin
    encoded_pos        = encode(mask);
    valid_out          = |unencoded_data;
    encoded_data_out   = encoded_pos;
  end

endmodule : mxn_encoder