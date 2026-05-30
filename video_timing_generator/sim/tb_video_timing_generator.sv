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

module tb_video_timing_generator ();
  logic                 clk         ;
  logic                 rst_n       ;
  logic          [ 2:0] resolution  ;
  logic                 active_video;
  logic                 hblank      ;
  logic                 vblank      ;
  logic                 hsync       ;
  logic                 vsync       ;
  logic          [11:0] pixel_x     ;
  logic          [11:0] pixel_y     ;
  logic                 line_start  ;
  logic                 frame_start ;
  int   unsigned        error_count ;

  VideoTimingGenerator uut (
    .clk         (clk         ),
    .rst_n       (rst_n       ),
    .resolution  (resolution  ),
    .active_video(active_video),
    .hblank      (hblank      ),
    .vblank      (vblank      ),
    .hsync       (hsync       ),
    .vsync       (vsync       ),
    .pixel_x     (pixel_x     ),
    .pixel_y     (pixel_y     ),
    .line_start  (line_start  ),
    .frame_start (frame_start )
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  function automatic int unsigned timing_value(input logic [11:0] value);
    begin
      return int'(value);
    end
  endfunction

  task report_error(input string message);
    begin
      error_count++;
      $error("%s", message);
      if (error_count > 20) begin
        $fatal(1, "Stopping after too many errors");
      end
    end
  endtask

  task check_outputs_at(
      input logic [2:0] mode,
      input string mode_name,
      input int unsigned x,
      input int unsigned y
    );
    video_timing_t timing;
    int unsigned hsync_start;
    int unsigned hsync_end;
    int unsigned vsync_start;
    int unsigned vsync_end;
    bit exp_hblank;
    bit exp_vblank;
    bit exp_active;
    bit exp_hsync_raw;
    bit exp_vsync_raw;
    bit exp_hsync;
    bit exp_vsync;
    begin
      timing = get_video_timing(mode);
      hsync_start = timing_value(timing.h_active) + timing_value(timing.h_front);
      hsync_end = hsync_start + timing_value(timing.h_sync);
      vsync_start = timing_value(timing.v_active) + timing_value(timing.v_front);
      vsync_end = vsync_start + timing_value(timing.v_sync);

      force uut.active_resolution = mode;
      force uut.h_counter = x[11:0];
      force uut.v_counter = y[11:0];
      #1;

      exp_hblank = (x >= timing_value(timing.h_active));
      exp_vblank = (y >= timing_value(timing.v_active));
      exp_active = !exp_hblank && !exp_vblank;
      exp_hsync_raw = (x >= hsync_start) && (x < hsync_end);
      exp_vsync_raw = (y >= vsync_start) && (y < vsync_end);
      exp_hsync = timing.hsync_active_high ? exp_hsync_raw : !exp_hsync_raw;
      exp_vsync = timing.vsync_active_high ? exp_vsync_raw : !exp_vsync_raw;

      if (pixel_x !== x[11:0]) report_error({mode_name, ": pixel_x mismatch"});
      if (pixel_y !== y[11:0]) report_error({mode_name, ": pixel_y mismatch"});
      if (hblank !== exp_hblank) report_error({mode_name, ": hblank mismatch"});
      if (vblank !== exp_vblank) report_error({mode_name, ": vblank mismatch"});
      if (active_video !== exp_active) report_error({mode_name, ": active_video mismatch"});
      if (hsync !== exp_hsync) report_error({mode_name, ": hsync mismatch"});
      if (vsync !== exp_vsync) report_error({mode_name, ": vsync mismatch"});
      if (line_start !== (x == 0)) report_error({mode_name, ": line_start mismatch"});
      if (frame_start !== ((x == 0) && (y == 0))) report_error({mode_name, ": frame_start mismatch"});

      release uut.h_counter;
      release uut.v_counter;
      release uut.active_resolution;
    end
  endtask

  task reset_mode(input logic [2:0] mode);
    begin
      resolution = mode;
      rst_n = 1'b0;
      repeat (2) @(posedge clk);
      #1;
      if (pixel_x !== 12'd0) report_error("reset: pixel_x mismatch");
      if (pixel_y !== 12'd0) report_error("reset: pixel_y mismatch");
      if (frame_start !== 1'b1) report_error("reset: frame_start mismatch");
      rst_n = 1'b1;
      @(posedge clk);
      #1;
    end
  endtask

  task check_counter_rollover(input logic [2:0] mode, input string mode_name);
    video_timing_t timing;
    logic [2:0] next_mode;
    begin
      timing = get_video_timing(mode);
      next_mode = (mode == VIDEO_720P) ? VIDEO_VGA : VIDEO_720P;
      reset_mode(mode);

      force uut.active_resolution = mode;
      force uut.h_counter = 12'd10;
      force uut.v_counter = 12'd20;
      release uut.h_counter;
      release uut.v_counter;
      @(posedge clk);
      #1;
      if (pixel_x !== 12'd11) report_error({mode_name, ": horizontal increment mismatch"});
      if (pixel_y !== 12'd20) report_error({mode_name, ": vertical hold mismatch"});

      force uut.h_counter = timing.h_total - 12'd1;
      force uut.v_counter = 12'd20;
      release uut.h_counter;
      release uut.v_counter;
      @(posedge clk);
      #1;
      if (pixel_x !== 12'd0) report_error({mode_name, ": line rollover x mismatch"});
      if (pixel_y !== 12'd21) report_error({mode_name, ": line rollover y mismatch"});

      resolution = next_mode;
      force uut.h_counter = timing.h_total - 12'd1;
      force uut.v_counter = timing.v_total - 12'd1;
      release uut.h_counter;
      release uut.v_counter;
      release uut.active_resolution;
      @(posedge clk);
      #1;
      if (pixel_x !== 12'd0) report_error({mode_name, ": frame rollover x mismatch"});
      if (pixel_y !== 12'd0) report_error({mode_name, ": frame rollover y mismatch"});
      if (frame_start !== 1'b1) report_error({mode_name, ": frame rollover start mismatch"});

      check_outputs_at(next_mode, {mode_name, " mode switch"}, 0, 0);
    end
  endtask

  task check_mode(input logic [2:0] mode, input string mode_name);
    video_timing_t timing;
    int unsigned h_active;
    int unsigned h_total;
    int unsigned hsync_start;
    int unsigned hsync_end;
    int unsigned v_active;
    int unsigned v_total;
    int unsigned vsync_start;
    int unsigned vsync_end;
    begin
      timing = get_video_timing(mode);
      h_active = timing_value(timing.h_active);
      h_total = timing_value(timing.h_total);
      hsync_start = h_active + timing_value(timing.h_front);
      hsync_end = hsync_start + timing_value(timing.h_sync);
      v_active = timing_value(timing.v_active);
      v_total = timing_value(timing.v_total);
      vsync_start = v_active + timing_value(timing.v_front);
      vsync_end = vsync_start + timing_value(timing.v_sync);

      $display("Checking %s timing boundaries", mode_name);
      check_outputs_at(mode, mode_name, 0, 0);
      check_outputs_at(mode, mode_name, h_active - 1, v_active - 1);
      check_outputs_at(mode, mode_name, h_active, 0);
      check_outputs_at(mode, mode_name, 0, v_active);
      check_outputs_at(mode, mode_name, hsync_start - 1, 0);
      check_outputs_at(mode, mode_name, hsync_start, 0);
      check_outputs_at(mode, mode_name, hsync_end - 1, 0);
      check_outputs_at(mode, mode_name, hsync_end, 0);
      check_outputs_at(mode, mode_name, 0, vsync_start - 1);
      check_outputs_at(mode, mode_name, 0, vsync_start);
      check_outputs_at(mode, mode_name, 0, vsync_end - 1);
      check_outputs_at(mode, mode_name, 0, vsync_end);
      check_outputs_at(mode, mode_name, h_total - 1, v_total - 1);
      check_counter_rollover(mode, mode_name);
    end
  endtask

  initial begin
    error_count = 0;
    resolution = VIDEO_720P;
    rst_n = 1'b0;

    check_mode(VIDEO_720P, "1280x720");
    check_mode(VIDEO_1080P, "1920x1080");
    check_mode(VIDEO_VGA, "640x480");
    check_mode(VIDEO_SVGA, "800x600");
    check_mode(VIDEO_XGA, "1024x768");

    if (error_count == 0) begin
      $display("PASS: all video timing checks completed");
    end else begin
      $fatal(1, "FAIL: %0d timing check errors", error_count);
    end

    $finish;
  end
endmodule : tb_video_timing_generator
