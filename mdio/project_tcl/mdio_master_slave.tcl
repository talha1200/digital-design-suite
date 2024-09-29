#*****************************************************************************************
# Vivado (TM) v2020.2 (64-bit)
#
# This file contains the Vivado Tcl commands for re-creating the project to the state*
# when this script was generated. In order to re-create the project, please source this
# file in the Vivado Tcl Shell.
#
# * Note that the runs in the created project will be configured the same way as the
#   original project, however they will not be launched automatically. To regenerate the
#   run results please launch the synthesis/implementation runs as needed.
#
#*****************************************************************************************
# Set the project name
set _xil_proj_name_ "mdio_master_slave"

variable script_file
set script_file "mdio_master_slave.tcl"

# CHANGE DESIGN NAME HERE
set design_name mdio_test

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Check file required for this script exists
proc checkRequiredFiles { origin_dir} {
  set status true
  set files [list \
   "$origin_dir/../sim/tb_master_mdio.sv" \
  ]
  foreach ifile $files {
    if { ![file isfile $ifile] } {
      puts " Could not find remote file $ifile "
      set status false
    }
  }

  set paths [list \
   [file normalize "$origin_dir/../user_ip"] \
  ]
  foreach ipath $paths {
    if { ![file isdirectory $ipath] } {
      puts " Could not access $ipath "
      set status false
    }
  }

  return $status
}

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}

# Use project name variable, if specified in the tcl shell
if { [info exists ::user_project_name] } {
  set _xil_proj_name_ $::user_project_name
}

# Help information for this script
proc print_help {} {
  variable script_file
  puts "\nDescription:"
  puts "Recreate a Vivado project from this script. The created project will be"
  puts "functionally equivalent to the original project for which this script was"
  puts "generated. The script contains commands for creating a project, filesets,"
  puts "runs, adding/importing sources and setting properties on various objects.\n"
  puts "Syntax:"
  puts "$script_file"
  puts "$script_file -tclargs \[--origin_dir <path>\]"
  puts "$script_file -tclargs \[--project_name <name>\]"
  puts "$script_file -tclargs \[--help\]\n"
  puts "Usage:"
  puts "Name                   Description"
  puts "-------------------------------------------------------------------------"
  puts "\[--origin_dir <path>\]  Determine source file paths wrt this path. Default"
  puts "                       origin_dir path value is \".\", otherwise, the value"
  puts "                       that was set with the \"-paths_relative_to\" switch"
  puts "                       when this script was generated.\n"
  puts "\[--project_name <name>\] Create project with the specified name. Default"
  puts "                       name is the name of the project from where this"
  puts "                       script was generated.\n"
  puts "\[--help\]               Print help information for this script"
  puts "-------------------------------------------------------------------------\n"
  exit 0
}

if { $::argc > 0 } {
  for {set i 0} {$i < $::argc} {incr i} {
    set option [string trim [lindex $::argv $i]]
    switch -regexp -- $option {
      "--origin_dir"   { incr i; set origin_dir [lindex $::argv $i] }
      "--project_name" { incr i; set _xil_proj_name_ [lindex $::argv $i] }
      "--help"         { print_help }
      default {
        if { [regexp {^-} $option] } {
          puts "ERROR: Unknown option '$option' specified, please type '$script_file -tclargs --help' for usage info.\n"
          return 1
        }
      }
    }
  }
}

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/project_tcl/mdio_master_prj"]"

# Check for paths and files needed for project creation
set validate_required 0
if { $validate_required } {
  if { [checkRequiredFiles $origin_dir] } {
    puts "Tcl file $script_file is valid. All files required for project creation is accesable. "
  } else {
    puts "Tcl file $script_file is not valid. Not all files required for project creation is accesable. "
    return
  }
}

# Create project
create_project ${_xil_proj_name_} ./${_xil_proj_name_} -part xc7z020clg484-1

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [current_project]
set_property -name "board_part" -value "em.avnet.com:zed:part0:1.4" -objects $obj
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_output_repo" -value "$proj_dir/${_xil_proj_name_}.cache/ip" -objects $obj
set_property -name "mem.enable_memory_map_generation" -value "1" -objects $obj
set_property -name "sim.central_dir" -value "$proj_dir/${_xil_proj_name_}.ip_user_files" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj
set_property -name "xpm_libraries" -value "XPM_CDC XPM_FIFO XPM_MEMORY" -objects $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set IP repository paths
set obj [get_filesets sources_1]
if { $obj != {} } {
   set_property "ip_repo_paths" "[file normalize "$origin_dir/../user_ip"]" $obj

   # Rebuild user ip_repo's index before adding any source files
   update_ip_catalog -rebuild
}

# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]
set_property -name "top" -value "mdio_test_wrapper" -objects $obj

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset properties
set obj [get_filesets constrs_1]

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
# Empty (no sources present)

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property -name "hbs.configure_design_for_hier_access" -value "1" -objects $obj
set_property -name "top" -value "mdio_test_wrapper" -objects $obj
set_property -name "top_auto_set" -value "0" -objects $obj


# Proc to create BD mdio_master_test
proc cr_bd_mdio_test { parentCell } {

  # CHANGE DESIGN NAME HERE
  set design_name mdio_test

  common::send_gid_msg -ssname BD::TCL -id 2010 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

  create_bd_design $design_name

  set bCheckIPsPassed 1
  ##################################################################
  # CHECK IPs
  ##################################################################
  set bCheckIPs 1
  if { $bCheckIPs == 1 } {
     set list_check_ips "\ 
  xilinx.com:ip:gmii_to_rgmii:4.1\
  user.org:user:mdio_master:1.0\
  user.org:user:mdio_slave:1.0\
  xilinx.com:ip:xlslice:1.0\
  "

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

  }

  if { $bCheckIPsPassed != 1 } {
    common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
    return 3
  }

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set GMII [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:gmii_rtl:1.0 GMII ]

  set RGMII [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 RGMII ]


  # Create ports
  set busy [ create_bd_port -dir O busy ]
  set clk [ create_bd_port -dir I -type clk clk ]
  set clkin [ create_bd_port -dir I -type clk clkin ]
  set clock_speed [ create_bd_port -dir O -from 1 -to 0 clock_speed ]
  set data_in [ create_bd_port -dir I -from 15 -to 0 data_in ]
  set data_out [ create_bd_port -dir O -from 15 -to 0 data_out ]
  set data_out_valid [ create_bd_port -dir O data_out_valid ]
  set duplex_status [ create_bd_port -dir O duplex_status ]
  set gmii_clk_125m_out [ create_bd_port -dir O -type clk gmii_clk_125m_out ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {125000000} \
 ] $gmii_clk_125m_out
  set gmii_clk_25m_out [ create_bd_port -dir O -type clk gmii_clk_25m_out ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {25000000} \
 ] $gmii_clk_25m_out
  set gmii_clk_2_5m_out [ create_bd_port -dir O -type clk gmii_clk_2_5m_out ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {2500000} \
 ] $gmii_clk_2_5m_out
  set link_status [ create_bd_port -dir O link_status ]
  set mmcm_locked_out [ create_bd_port -dir O mmcm_locked_out ]
  set phy_addr [ create_bd_port -dir I -from 4 -to 0 phy_addr ]
  set ref_clk_out [ create_bd_port -dir O -type clk ref_clk_out ]
  set reg0 [ create_bd_port -dir O -from 15 -to 0 reg0 ]
  set reg1 [ create_bd_port -dir O -from 15 -to 0 reg1 ]
  set reg2 [ create_bd_port -dir O -from 15 -to 0 reg2 ]
  set reg3 [ create_bd_port -dir O -from 15 -to 0 reg3 ]
  set reg_addr [ create_bd_port -dir I -from 4 -to 0 reg_addr ]
  set rst_n [ create_bd_port -dir I -type rst rst_n ]
  set rx_reset [ create_bd_port -dir I -type rst rx_reset ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $rx_reset
  set speed_mode [ create_bd_port -dir O -from 1 -to 0 speed_mode ]
  set start [ create_bd_port -dir I start ]
  set tx_reset [ create_bd_port -dir I -type rst tx_reset ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $tx_reset
  set write_en [ create_bd_port -dir I write_en ]

  # Create instance: gmii_to_rgmii_0, and set properties
  set gmii_to_rgmii_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:gmii_to_rgmii:4.1 gmii_to_rgmii_0 ]
  set_property -dict [ list \
   CONFIG.SupportLevel {Include_Shared_Logic_in_Core} \
 ] $gmii_to_rgmii_0

  # Create instance: mdio_master_0, and set properties
  set mdio_master_0 [ create_bd_cell -type ip -vlnv user.org:user:mdio_master:1.0 mdio_master_0 ]

  # Create instance: mdio_slave_0, and set properties
  set mdio_slave_0 [ create_bd_cell -type ip -vlnv user.org:user:mdio_slave:1.0 mdio_slave_0 ]
  set_property -dict [ list \
   CONFIG.PHY_ADDR {1} \
 ] $mdio_slave_0

  # Create instance: reg0, and set properties
  set reg0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 reg0 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {15} \
   CONFIG.DIN_TO {0} \
   CONFIG.DIN_WIDTH {64} \
   CONFIG.DOUT_WIDTH {16} \
 ] $reg0

  # Create instance: reg1, and set properties
  set reg1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 reg1 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {31} \
   CONFIG.DIN_TO {16} \
   CONFIG.DIN_WIDTH {64} \
   CONFIG.DOUT_WIDTH {16} \
 ] $reg1

  # Create instance: reg2, and set properties
  set reg2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 reg2 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {47} \
   CONFIG.DIN_TO {32} \
   CONFIG.DIN_WIDTH {64} \
   CONFIG.DOUT_WIDTH {16} \
 ] $reg2

  # Create instance: reg3, and set properties
  set reg3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 reg3 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {63} \
   CONFIG.DIN_TO {48} \
   CONFIG.DIN_WIDTH {64} \
   CONFIG.DOUT_WIDTH {16} \
 ] $reg3

  # Create interface connections
  connect_bd_intf_net -intf_net GMII_0_1 [get_bd_intf_ports GMII] [get_bd_intf_pins gmii_to_rgmii_0/GMII]
  connect_bd_intf_net -intf_net gmii_to_rgmii_0_RGMII [get_bd_intf_ports RGMII] [get_bd_intf_pins gmii_to_rgmii_0/RGMII]
  connect_bd_intf_net -intf_net mdio_master_0_mdio [get_bd_intf_pins gmii_to_rgmii_0/MDIO_GEM] [get_bd_intf_pins mdio_master_0/mdio]

  # Create port connections
  connect_bd_net -net clk_0_1 [get_bd_ports clk] [get_bd_pins mdio_master_0/clk]
  connect_bd_net -net clkin_0_1 [get_bd_ports clkin] [get_bd_pins gmii_to_rgmii_0/clkin]
  connect_bd_net -net data_in_0_1 [get_bd_ports data_in] [get_bd_pins mdio_master_0/data_in]
  connect_bd_net -net gmii_to_rgmii_0_clock_speed [get_bd_ports clock_speed] [get_bd_pins gmii_to_rgmii_0/clock_speed]
  connect_bd_net -net gmii_to_rgmii_0_duplex_status [get_bd_ports duplex_status] [get_bd_pins gmii_to_rgmii_0/duplex_status]
  connect_bd_net -net gmii_to_rgmii_0_gmii_clk_125m_out [get_bd_ports gmii_clk_125m_out] [get_bd_pins gmii_to_rgmii_0/gmii_clk_125m_out]
  connect_bd_net -net gmii_to_rgmii_0_gmii_clk_25m_out [get_bd_ports gmii_clk_25m_out] [get_bd_pins gmii_to_rgmii_0/gmii_clk_25m_out]
  connect_bd_net -net gmii_to_rgmii_0_gmii_clk_2_5m_out [get_bd_ports gmii_clk_2_5m_out] [get_bd_pins gmii_to_rgmii_0/gmii_clk_2_5m_out]
  connect_bd_net -net gmii_to_rgmii_0_link_status [get_bd_ports link_status] [get_bd_pins gmii_to_rgmii_0/link_status]
  connect_bd_net -net gmii_to_rgmii_0_mdio_phy_mdc [get_bd_pins gmii_to_rgmii_0/mdio_phy_mdc] [get_bd_pins mdio_slave_0/mdio_mdc]
  connect_bd_net -net gmii_to_rgmii_0_mdio_phy_o [get_bd_pins gmii_to_rgmii_0/mdio_phy_o] [get_bd_pins mdio_slave_0/mdio_o]
  connect_bd_net -net gmii_to_rgmii_0_mdio_phy_t [get_bd_pins gmii_to_rgmii_0/mdio_phy_t] [get_bd_pins mdio_slave_0/mdio_t]
  connect_bd_net -net gmii_to_rgmii_0_mmcm_locked_out [get_bd_ports mmcm_locked_out] [get_bd_pins gmii_to_rgmii_0/mmcm_locked_out]
  connect_bd_net -net gmii_to_rgmii_0_ref_clk_out [get_bd_ports ref_clk_out] [get_bd_pins gmii_to_rgmii_0/ref_clk_out]
  connect_bd_net -net gmii_to_rgmii_0_speed_mode [get_bd_ports speed_mode] [get_bd_pins gmii_to_rgmii_0/speed_mode]
  connect_bd_net -net mdio_master_0_busy [get_bd_ports busy] [get_bd_pins mdio_master_0/busy]
  connect_bd_net -net mdio_master_0_data_out [get_bd_ports data_out] [get_bd_pins mdio_master_0/data_out]
  connect_bd_net -net mdio_master_0_data_out_valid [get_bd_ports data_out_valid] [get_bd_pins mdio_master_0/data_out_valid]
  connect_bd_net -net mdio_slave_0_mdio_gem_i [get_bd_pins gmii_to_rgmii_0/mdio_phy_i] [get_bd_pins mdio_slave_0/mdio_i]
  connect_bd_net -net mdio_slave_0_reg0 [get_bd_ports reg0] [get_bd_pins reg0/Dout]
  connect_bd_net -net mdio_slave_0_reg1 [get_bd_ports reg1] [get_bd_pins reg1/Dout]
  connect_bd_net -net mdio_slave_0_reg2 [get_bd_ports reg2] [get_bd_pins reg2/Dout]
  connect_bd_net -net mdio_slave_0_reg3 [get_bd_ports reg3] [get_bd_pins reg3/Dout]
  connect_bd_net -net mdio_slave_0_slave_reg [get_bd_pins mdio_slave_0/slave_reg] [get_bd_pins reg0/Din] [get_bd_pins reg1/Din] [get_bd_pins reg2/Din] [get_bd_pins reg3/Din]
  connect_bd_net -net phy_addr_0_1 [get_bd_ports phy_addr] [get_bd_pins mdio_master_0/phy_addr]
  connect_bd_net -net reg_addr_0_1 [get_bd_ports reg_addr] [get_bd_pins mdio_master_0/reg_addr]
  connect_bd_net -net rst_n_0_1 [get_bd_ports rst_n] [get_bd_pins mdio_master_0/rst_n] [get_bd_pins mdio_slave_0/rst_n]
  connect_bd_net -net rx_reset_0_1 [get_bd_ports rx_reset] [get_bd_pins gmii_to_rgmii_0/rx_reset]
  connect_bd_net -net start_0_1 [get_bd_ports start] [get_bd_pins mdio_master_0/start]
  connect_bd_net -net tx_reset_0_1 [get_bd_ports tx_reset] [get_bd_pins gmii_to_rgmii_0/tx_reset]
  connect_bd_net -net write_en_0_1 [get_bd_ports write_en] [get_bd_pins mdio_master_0/write_en]

  # Create address segments

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   "ActiveEmotionalView":"Default View",
   "Default View_ScaleFactor":"0.460748",
   "Default View_TopLeft":"-1374,0",
   "ExpandedHierarchyInLayout":"",
   "guistr":"# # String gsaved with Nlview 7.0r4  2019-12-20 bk=1.5203 VDI=41 GEI=36 GUI=JA:10.0 TLS
#  -string -flagsOSRD
preplace port RGMII -pg 1 -lvl 3 -x 680 -y 170 -defaultsOSRD
preplace port GMII -pg 1 -lvl 0 -x 0 -y 190 -defaultsOSRD
preplace port ref_clk_out -pg 1 -lvl 3 -x 680 -y 190 -defaultsOSRD
preplace port mmcm_locked_out -pg 1 -lvl 3 -x 680 -y 210 -defaultsOSRD
preplace port gmii_clk_125m_out -pg 1 -lvl 3 -x 680 -y 230 -defaultsOSRD
preplace port gmii_clk_25m_out -pg 1 -lvl 3 -x 680 -y 250 -defaultsOSRD
preplace port gmii_clk_2_5m_out -pg 1 -lvl 3 -x 680 -y 270 -defaultsOSRD
preplace port link_status -pg 1 -lvl 3 -x 680 -y 290 -defaultsOSRD
preplace port duplex_status -pg 1 -lvl 3 -x 680 -y 330 -defaultsOSRD
preplace port tx_reset -pg 1 -lvl 0 -x 0 -y 210 -defaultsOSRD
preplace port rx_reset -pg 1 -lvl 0 -x 0 -y 230 -defaultsOSRD
preplace port clkin -pg 1 -lvl 0 -x 0 -y 250 -defaultsOSRD
preplace port rst_n -pg 1 -lvl 0 -x 0 -y 750 -defaultsOSRD
preplace port write_en -pg 1 -lvl 0 -x 0 -y 930 -defaultsOSRD
preplace port clk -pg 1 -lvl 0 -x 0 -y 890 -defaultsOSRD
preplace port start -pg 1 -lvl 0 -x 0 -y 1010 -defaultsOSRD
preplace port busy -pg 1 -lvl 3 -x 680 -y 940 -defaultsOSRD
preplace port data_out_valid -pg 1 -lvl 3 -x 680 -y 960 -defaultsOSRD
preplace portBus clock_speed -pg 1 -lvl 3 -x 680 -y 310 -defaultsOSRD
preplace portBus speed_mode -pg 1 -lvl 3 -x 680 -y 350 -defaultsOSRD
preplace portBus data_in -pg 1 -lvl 0 -x 0 -y 990 -defaultsOSRD
preplace portBus phy_addr -pg 1 -lvl 0 -x 0 -y 950 -defaultsOSRD
preplace portBus reg_addr -pg 1 -lvl 0 -x 0 -y 970 -defaultsOSRD
preplace portBus data_out -pg 1 -lvl 3 -x 680 -y 980 -defaultsOSRD
preplace portBus reg1 -pg 1 -lvl 3 -x 680 -y 550 -defaultsOSRD
preplace portBus reg0 -pg 1 -lvl 3 -x 680 -y 450 -defaultsOSRD
preplace portBus reg2 -pg 1 -lvl 3 -x 680 -y 650 -defaultsOSRD
preplace portBus reg3 -pg 1 -lvl 3 -x 680 -y 750 -defaultsOSRD
preplace inst gmii_to_rgmii_0 -pg 1 -lvl 2 -x 490 -y 210 -defaultsOSRD
preplace inst mdio_master_0 -pg 1 -lvl 1 -x 190 -y 950 -defaultsOSRD
preplace inst reg0 -pg 1 -lvl 2 -x 490 -y 450 -defaultsOSRD
preplace inst reg1 -pg 1 -lvl 2 -x 490 -y 550 -defaultsOSRD
preplace inst reg2 -pg 1 -lvl 2 -x 490 -y 650 -defaultsOSRD
preplace inst reg3 -pg 1 -lvl 2 -x 490 -y 750 -defaultsOSRD
preplace inst mdio_slave_0 -pg 1 -lvl 1 -x 190 -y 700 -defaultsOSRD
preplace netloc gmii_to_rgmii_0_ref_clk_out 1 2 1 NJ 190
preplace netloc gmii_to_rgmii_0_mmcm_locked_out 1 2 1 NJ 210
preplace netloc gmii_to_rgmii_0_gmii_clk_125m_out 1 2 1 NJ 230
preplace netloc gmii_to_rgmii_0_gmii_clk_25m_out 1 2 1 NJ 250
preplace netloc gmii_to_rgmii_0_gmii_clk_2_5m_out 1 2 1 NJ 270
preplace netloc gmii_to_rgmii_0_link_status 1 2 1 NJ 290
preplace netloc gmii_to_rgmii_0_duplex_status 1 2 1 NJ 330
preplace netloc gmii_to_rgmii_0_clock_speed 1 2 1 NJ 310
preplace netloc gmii_to_rgmii_0_speed_mode 1 2 1 NJ 350
preplace netloc tx_reset_0_1 1 0 2 NJ 210 NJ
preplace netloc rx_reset_0_1 1 0 2 NJ 230 NJ
preplace netloc clkin_0_1 1 0 2 NJ 250 NJ
preplace netloc data_in_0_1 1 0 1 NJ 990
preplace netloc rst_n_0_1 1 0 1 20 750n
preplace netloc phy_addr_0_1 1 0 1 NJ 950
preplace netloc write_en_0_1 1 0 1 NJ 930
preplace netloc reg_addr_0_1 1 0 1 NJ 970
preplace netloc clk_0_1 1 0 1 NJ 890
preplace netloc start_0_1 1 0 1 NJ 1010
preplace netloc mdio_master_0_busy 1 1 2 NJ 940 NJ
preplace netloc mdio_master_0_data_out_valid 1 1 2 NJ 960 NJ
preplace netloc mdio_master_0_data_out 1 1 2 NJ 980 NJ
preplace netloc gmii_to_rgmii_0_mdio_phy_mdc 1 0 3 40 10 NJ 10 660
preplace netloc mdio_slave_0_mdio_gem_i 1 0 3 50 810 NJ 810 660
preplace netloc gmii_to_rgmii_0_mdio_phy_o 1 0 3 30 820 NJ 820 650
preplace netloc gmii_to_rgmii_0_mdio_phy_t 1 0 3 40 830 NJ 830 640
preplace netloc mdio_slave_0_reg1 1 2 1 NJ 550
preplace netloc mdio_slave_0_reg0 1 2 1 NJ 450
preplace netloc mdio_slave_0_reg2 1 2 1 NJ 650
preplace netloc mdio_slave_0_reg3 1 2 1 NJ 750
preplace netloc mdio_slave_0_slave_reg 1 1 1 340 450n
preplace netloc mdio_master_0_mdio 1 1 1 330 170n
preplace netloc gmii_to_rgmii_0_RGMII 1 2 1 NJ 170
preplace netloc GMII_0_1 1 0 2 NJ 190 NJ
levelinfo -pg 1 0 190 490 680
pagesize -pg 1 -db -bbox -sgen -150 0 870 1070
"
}

  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
  close_bd_design $design_name 
}
# End of cr_bd_mdio_master_test()
cr_bd_mdio_test ""
# Generate the wrapper

make_wrapper -files [get_files $origin_dir/mdio_master_slave/mdio_master_slave.srcs/sources_1/bd/mdio_test/mdio_test.bd] -top
add_files -norecurse $origin_dir/mdio_master_slave/mdio_master_slave.gen/sources_1/bd/mdio_test/hdl/mdio_test_wrapper.v

# Update the compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

open_bd_design [get_files ${design_name}.bd]

# Add testbench files to the simulation set
add_files -fileset sim_1 [glob $origin_dir/../sim/*.sv]

# Create and configure the simulation
# Create the simulation set if not already created
if {[get_filesets sim_1] == ""} {
    create_fileset sim_1 -type simulation
}

# Set the top module for simulation in the simulation set
set_property top tb_master_mdio [get_filesets sim_1]

# Launch the simulation
launch_simulation

# Run the simulation for a specified time
run 1000ns