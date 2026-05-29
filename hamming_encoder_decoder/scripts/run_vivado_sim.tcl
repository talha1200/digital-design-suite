# Run the Hamming SECDED simulation in Vivado batch mode.
# Usage from this directory:
#   vivado -mode batch -source run_vivado_sim.tcl

set RTL_DIR   [file normalize [file join [file dirname [info script]] "../rtl"]]
set TB_DIR    [file normalize [file join [file dirname [info script]] "../tb"]]
set LOG_DIR   [file normalize [file join [file dirname [info script]] "../results/simulation_logs"]]
set PROJ_DIR  [file normalize [file join [file dirname [info script]] "../results/vivado_hamming_sim"]]

if {[info exists ::env(VIVADO_PART)]} {
  set PART $::env(VIVADO_PART)
} else {
  set PART xc7a35tcpg236-1
}

file mkdir $LOG_DIR

create_project hamming_sim $PROJ_DIR -part $PART -force

add_files -fileset sources_1 [list \
  [file join $RTL_DIR hamming_encoder.sv] \
  [file join $RTL_DIR hamming_decoder.sv] \
]

add_files -fileset sim_1 [list \
  [file join $TB_DIR tb_hamming.sv] \
]

set_property top tb_hamming [get_filesets sim_1]
update_compile_order -fileset sim_1

launch_simulation -simset sim_1 -mode batch
run all
close_sim
close_project
