`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2026 Talha Mahboob
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
import video_timing_pkg::*;

module video_timing_generator (
  input  logic        clk         ,
  input  logic        rst_n       ,
  input  logic [ 2:0] resolution  ,
  output logic        active_video,
  output logic        hblank      ,
  output logic        vblank      ,
  output logic        hsync       ,
  output logic        vsync       ,
  output logic [11:0] pixel_x     ,
  output logic [11:0] pixel_y     ,
  output logic        line_start  ,
  output logic        frame_start
);

  //--------------------------------------------------------------
  // Internal signals
  //--------------------------------------------------------------

  video_timing_t timing           ;
  logic [ 2:0]   active_resolution;
  logic [11:0]   h_counter        ;
  logic [11:0]   v_counter        ;
  logic          hsync_active     ;
  logic          vsync_active     ;
  logic          end_of_line      ;
  logic          end_of_frame     ;

  //--------------------------------------------------------------
  // Video timing generation logic
  //--------------------------------------------------------------

  always_comb begin
    timing = get_video_timing(active_resolution);
  end

  assign end_of_line  = (h_counter == timing.h_total - 12'd1);
  assign end_of_frame = end_of_line && (v_counter == timing.v_total - 12'd1);

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      h_counter         <= 0;
      v_counter         <= 0;
      active_resolution <= resolution;
    end else if (end_of_frame) begin
      h_counter         <= 0;
      v_counter         <= 0;
      active_resolution <= resolution;
    end else if (end_of_line) begin
      h_counter <= 0;
      v_counter <= v_counter + 1;
    end else begin
      h_counter <= h_counter + 1;
    end
  end

  assign hblank       = (h_counter >= timing.h_active);
  assign vblank       = (v_counter >= timing.v_active);
  assign active_video = !hblank && !vblank;

  assign hsync_active = (h_counter >= timing.h_active + timing.h_front) &&
    (h_counter <  timing.h_active + timing.h_front + timing.h_sync);
  assign vsync_active = (v_counter >= timing.v_active + timing.v_front) &&
    (v_counter <  timing.v_active + timing.v_front + timing.v_sync);

  assign hsync = timing.hsync_active_high ? hsync_active : !hsync_active;
  assign vsync = timing.vsync_active_high ? vsync_active : !vsync_active;

  assign pixel_x     = h_counter;
  assign pixel_y     = v_counter;
  assign line_start  = (h_counter == 0);
  assign frame_start = (h_counter == 0) && (v_counter == 0);

  //--------------------------------------------------------------
  // Assertions
  //--------------------------------------------------------------

  `ifdef VIDEO_TIMING_ASSERTIONS
    always_ff @(posedge clk) begin
      if (rst_n) begin
        assert (timing.h_total == timing.h_active + timing.h_front + timing.h_sync + timing.h_back);
        assert (timing.v_total == timing.v_active + timing.v_front + timing.v_sync + timing.v_back);
        assert (!active_video || (!hsync_active && !vsync_active));
      end
    end
  `endif

endmodule : video_timing_generator
