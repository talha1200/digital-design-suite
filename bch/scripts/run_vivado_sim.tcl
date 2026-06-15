# Run the BCH simulation in Vivado batch mode.
# Usage from the bch/ directory:
#   vivado -mode batch -source scripts/run_vivado_sim.tcl

set ROOT_DIR [file normalize [file join [file dirname [info script]] ".."]]
set RTL_DIR  [file join $ROOT_DIR "rtl"]
set TB_DIR   [file join $ROOT_DIR "tb"]
set PROJ_DIR [file join $ROOT_DIR "results/vivado_bch_sim"]

if {[info exists ::env(VIVADO_PART)]} {
  set PART $::env(VIVADO_PART)
} else {
  set PART xc7a35tcpg236-1
}

# Generate test vectors before launching simulation.
puts "--- Generating BCH vectors ---"
if {[catch {exec python3 [file join $ROOT_DIR scripts gen_vectors.py]} gen_out]} {
  error "Vector generation failed:\n$gen_out"
}
puts $gen_out

create_project bch_sim $PROJ_DIR -part $PART -force

# bch_pkg.sv must be added before the modules that import it.
add_files -fileset sources_1 [list \
  [file join $RTL_DIR bch_pkg.sv]     \
  [file join $RTL_DIR bch_encoder.sv] \
  [file join $RTL_DIR bch_decoder.sv] \
]

add_files -fileset sim_1 [list \
  [file join $TB_DIR tb_bch.sv] \
]

set_property top tb_bch [get_filesets sim_1]
update_compile_order -fileset sim_1

launch_simulation -simset sim_1 -mode batch
run all
close_sim
close_project
