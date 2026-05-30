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
package video_timing_pkg;
  localparam logic [2:0] VIDEO_720P  = 3'd0;
  localparam logic [2:0] VIDEO_1080P = 3'd1;
  localparam logic [2:0] VIDEO_VGA   = 3'd2;
  localparam logic [2:0] VIDEO_SVGA  = 3'd3;
  localparam logic [2:0] VIDEO_XGA   = 3'd4;

  typedef struct packed {
    logic [11:0] h_total          ;
    logic [11:0] h_active         ;
    logic [11:0] h_front          ;
    logic [11:0] h_sync           ;
    logic [11:0] h_back           ;
    logic [11:0] v_total          ;
    logic [11:0] v_active         ;
    logic [11:0] v_front          ;
    logic [11:0] v_sync           ;
    logic [11:0] v_back           ;
    logic        hsync_active_high;
    logic        vsync_active_high;
  } video_timing_t;

  // 640x480 VGA, 25.175 MHz pixel clock, negative sync.
  localparam logic [11:0] H_TOTAL_VGA  = 12'd800                                             ;
  localparam logic [11:0] H_SYNC_VGA   = 12'd96                                              ;
  localparam logic [11:0] H_BACK_VGA   = 12'd48                                              ;
  localparam logic [11:0] H_ACTIVE_VGA = 12'd640                                             ;
  localparam logic [11:0] H_FRONT_VGA  = H_TOTAL_VGA - H_ACTIVE_VGA - H_SYNC_VGA - H_BACK_VGA;
  localparam logic [11:0] V_TOTAL_VGA  = 12'd525                                             ;
  localparam logic [11:0] V_SYNC_VGA   = 12'd2                                               ;
  localparam logic [11:0] V_BACK_VGA   = 12'd33                                              ;
  localparam logic [11:0] V_ACTIVE_VGA = 12'd480                                             ;
  localparam logic [11:0] V_FRONT_VGA  = V_TOTAL_VGA - V_ACTIVE_VGA - V_SYNC_VGA - V_BACK_VGA;

  // 800x600 SVGA, 40 MHz pixel clock, positive sync.
  localparam logic [11:0] H_TOTAL_SVGA  = 12'd1056                                                ;
  localparam logic [11:0] H_SYNC_SVGA   = 12'd128                                                 ;
  localparam logic [11:0] H_BACK_SVGA   = 12'd88                                                  ;
  localparam logic [11:0] H_ACTIVE_SVGA = 12'd800                                                 ;
  localparam logic [11:0] H_FRONT_SVGA  = H_TOTAL_SVGA - H_ACTIVE_SVGA - H_SYNC_SVGA - H_BACK_SVGA;
  localparam logic [11:0] V_TOTAL_SVGA  = 12'd628                                                 ;
  localparam logic [11:0] V_SYNC_SVGA   = 12'd4                                                   ;
  localparam logic [11:0] V_BACK_SVGA   = 12'd23                                                  ;
  localparam logic [11:0] V_ACTIVE_SVGA = 12'd600                                                 ;
  localparam logic [11:0] V_FRONT_SVGA  = V_TOTAL_SVGA - V_ACTIVE_SVGA - V_SYNC_SVGA - V_BACK_SVGA;

  // 1024x768 XGA, 65 MHz pixel clock, negative sync.
  localparam logic [11:0] H_TOTAL_XGA  = 12'd1344                                            ;
  localparam logic [11:0] H_SYNC_XGA   = 12'd136                                             ;
  localparam logic [11:0] H_BACK_XGA   = 12'd160                                             ;
  localparam logic [11:0] H_ACTIVE_XGA = 12'd1024                                            ;
  localparam logic [11:0] H_FRONT_XGA  = H_TOTAL_XGA - H_ACTIVE_XGA - H_SYNC_XGA - H_BACK_XGA;
  localparam logic [11:0] V_TOTAL_XGA  = 12'd806                                             ;
  localparam logic [11:0] V_SYNC_XGA   = 12'd6                                               ;
  localparam logic [11:0] V_BACK_XGA   = 12'd29                                              ;
  localparam logic [11:0] V_ACTIVE_XGA = 12'd768                                             ;
  localparam logic [11:0] V_FRONT_XGA  = V_TOTAL_XGA - V_ACTIVE_XGA - V_SYNC_XGA - V_BACK_XGA;

  // 1280x720, 74.25 MHz pixel clock, positive sync.
  localparam logic [11:0] H_TOTAL_720  = 12'd1650                                            ;
  localparam logic [11:0] H_SYNC_720   = 12'd40                                              ;
  localparam logic [11:0] H_BACK_720   = 12'd220                                             ;
  localparam logic [11:0] H_ACTIVE_720 = 12'd1280                                            ;
  localparam logic [11:0] H_FRONT_720  = H_TOTAL_720 - H_ACTIVE_720 - H_SYNC_720 - H_BACK_720;
  localparam logic [11:0] V_TOTAL_720  = 12'd750                                             ;
  localparam logic [11:0] V_SYNC_720   = 12'd5                                               ;
  localparam logic [11:0] V_BACK_720   = 12'd20                                              ;
  localparam logic [11:0] V_ACTIVE_720 = 12'd720                                             ;
  localparam logic [11:0] V_FRONT_720  = V_TOTAL_720 - V_ACTIVE_720 - V_SYNC_720 - V_BACK_720;

  // 1920x1080, 148.5 MHz pixel clock, positive sync.
  localparam logic [11:0] H_TOTAL_1080  = 12'd2200                                                ;
  localparam logic [11:0] H_SYNC_1080   = 12'd44                                                  ;
  localparam logic [11:0] H_BACK_1080   = 12'd148                                                 ;
  localparam logic [11:0] H_ACTIVE_1080 = 12'd1920                                                ;
  localparam logic [11:0] H_FRONT_1080  = H_TOTAL_1080 - H_ACTIVE_1080 - H_SYNC_1080 - H_BACK_1080;
  localparam logic [11:0] V_TOTAL_1080  = 12'd1125                                                ;
  localparam logic [11:0] V_SYNC_1080   = 12'd5                                                   ;
  localparam logic [11:0] V_BACK_1080   = 12'd36                                                  ;
  localparam logic [11:0] V_ACTIVE_1080 = 12'd1080                                                ;
  localparam logic [11:0] V_FRONT_1080  = V_TOTAL_1080 - V_ACTIVE_1080 - V_SYNC_1080 - V_BACK_1080;

  function automatic video_timing_t get_video_timing(input logic [2:0] resolution);
    video_timing_t timing;
    begin
      case (resolution)
        VIDEO_1080P : begin
          timing.h_total = H_TOTAL_1080;
          timing.h_active = H_ACTIVE_1080;
          timing.h_front = H_FRONT_1080;
          timing.h_sync = H_SYNC_1080;
          timing.h_back = H_BACK_1080;
          timing.v_total = V_TOTAL_1080;
          timing.v_active = V_ACTIVE_1080;
          timing.v_front = V_FRONT_1080;
          timing.v_sync = V_SYNC_1080;
          timing.v_back = V_BACK_1080;
          timing.hsync_active_high = 1'b1;
          timing.vsync_active_high = 1'b1;
        end
        VIDEO_VGA : begin
          timing.h_total = H_TOTAL_VGA;
          timing.h_active = H_ACTIVE_VGA;
          timing.h_front = H_FRONT_VGA;
          timing.h_sync = H_SYNC_VGA;
          timing.h_back = H_BACK_VGA;
          timing.v_total = V_TOTAL_VGA;
          timing.v_active = V_ACTIVE_VGA;
          timing.v_front = V_FRONT_VGA;
          timing.v_sync = V_SYNC_VGA;
          timing.v_back = V_BACK_VGA;
          timing.hsync_active_high = 1'b0;
          timing.vsync_active_high = 1'b0;
        end
        VIDEO_SVGA : begin
          timing.h_total = H_TOTAL_SVGA;
          timing.h_active = H_ACTIVE_SVGA;
          timing.h_front = H_FRONT_SVGA;
          timing.h_sync = H_SYNC_SVGA;
          timing.h_back = H_BACK_SVGA;
          timing.v_total = V_TOTAL_SVGA;
          timing.v_active = V_ACTIVE_SVGA;
          timing.v_front = V_FRONT_SVGA;
          timing.v_sync = V_SYNC_SVGA;
          timing.v_back = V_BACK_SVGA;
          timing.hsync_active_high = 1'b1;
          timing.vsync_active_high = 1'b1;
        end
        VIDEO_XGA : begin
          timing.h_total = H_TOTAL_XGA;
          timing.h_active = H_ACTIVE_XGA;
          timing.h_front = H_FRONT_XGA;
          timing.h_sync = H_SYNC_XGA;
          timing.h_back = H_BACK_XGA;
          timing.v_total = V_TOTAL_XGA;
          timing.v_active = V_ACTIVE_XGA;
          timing.v_front = V_FRONT_XGA;
          timing.v_sync = V_SYNC_XGA;
          timing.v_back = V_BACK_XGA;
          timing.hsync_active_high = 1'b0;
          timing.vsync_active_high = 1'b0;
        end
        default : begin
          timing.h_total = H_TOTAL_720;
          timing.h_active = H_ACTIVE_720;
          timing.h_front = H_FRONT_720;
          timing.h_sync = H_SYNC_720;
          timing.h_back = H_BACK_720;
          timing.v_total = V_TOTAL_720;
          timing.v_active = V_ACTIVE_720;
          timing.v_front = V_FRONT_720;
          timing.v_sync = V_SYNC_720;
          timing.v_back = V_BACK_720;
          timing.hsync_active_high = 1'b1;
          timing.vsync_active_high = 1'b1;
        end
      endcase

      return timing;
    end
  endfunction
endpackage : video_timing_pkg
