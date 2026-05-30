###############################################################################
# Copyright (c) 2026 Talha Mahboob
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
###############################################################################
# run_sim.tcl
# Usage (Vivado Tcl console or batch mode):
#   source run_sim.tcl
#   vivado -mode batch -source run_sim.tcl
###############################################################################

set SCRIPT_DIR [file normalize [file dirname [info script]]]

# ── Project settings ────────────────────────────────────────────────────────
set PROJECT_NAME  "video_timing_generator"
set PROJECT_DIR   "$SCRIPT_DIR/vivado_project"
set PART          "xc7a35tcpg236-1"

# ── Source files ─────────────────────────────────────────────────────────────
set RTL_SRCS [list \
  "$SCRIPT_DIR/rtl/video_timing_pkg.sv"    \
  "$SCRIPT_DIR/rtl/video_timing_generator.sv" \
]

set SIM_SRCS [list \
  "$SCRIPT_DIR/sim/tb_video_timing_generator.sv" \
]

set TOP_MODULE    "video_timing_generator"
set TB_MODULE     "tb_video_timing_generator"
set SIM_TIME      "10ms"

###############################################################################
# Create / open project
###############################################################################
if {[file exists "$PROJECT_DIR/${PROJECT_NAME}.xpr"]} {
  puts "INFO: Opening existing project at $PROJECT_DIR/${PROJECT_NAME}.xpr"
  open_project "$PROJECT_DIR/${PROJECT_NAME}.xpr"
} else {
  puts "INFO: Creating new project: $PROJECT_NAME"
  file mkdir $PROJECT_DIR
  create_project $PROJECT_NAME $PROJECT_DIR -part $PART -force

  set_property target_language  SystemVerilog [current_project]
  set_property simulator_language Mixed       [current_project]
  set_property default_lib       xil_defaultlib [current_project]

  # RTL sources
  add_files -norecurse $RTL_SRCS
  set_property file_type {SystemVerilog} [get_files $RTL_SRCS]

  # Simulation-only sources
  add_files -fileset sim_1 -norecurse $SIM_SRCS
  set_property file_type {SystemVerilog} [get_files -of_objects [get_filesets sim_1] $SIM_SRCS]

  # Fileset properties
  set_property top            $TOP_MODULE [get_filesets sources_1]
  set_property top            $TB_MODULE  [get_filesets sim_1]
  set_property top_lib        xil_defaultlib [get_filesets sim_1]

  # Enable VIDEO_TIMING_ASSERTIONS in simulation
  set_property verilog_define "VIDEO_TIMING_ASSERTIONS" [get_filesets sim_1]

  puts "INFO: Project created successfully."
}

###############################################################################
# Run simulation
###############################################################################
puts "INFO: Launching simulation..."

launch_simulation -simset sim_1 -mode behavioral

run $SIM_TIME

puts "INFO: Simulation finished."

# Add key waveforms
add_wave /tb_video_timing_generator/clk
add_wave /tb_video_timing_generator/rst_n
add_wave /tb_video_timing_generator/resolution
add_wave /tb_video_timing_generator/active_video
add_wave /tb_video_timing_generator/hblank
add_wave /tb_video_timing_generator/vblank
add_wave /tb_video_timing_generator/hsync
add_wave /tb_video_timing_generator/vsync
add_wave /tb_video_timing_generator/pixel_x
add_wave /tb_video_timing_generator/pixel_y
add_wave /tb_video_timing_generator/line_start
add_wave /tb_video_timing_generator/frame_start

puts "INFO: All done. Check the waveform viewer or transcript for PASS/FAIL."
