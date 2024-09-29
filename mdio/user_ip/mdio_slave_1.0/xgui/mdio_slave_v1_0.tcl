# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "PHY_ADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SLAVE_ID" -parent ${Page_0}

  ipgui::add_param $IPINST -name "NUM_REG"

}

proc update_PARAM_VALUE.NUM_REG { PARAM_VALUE.NUM_REG } {
	# Procedure called to update NUM_REG when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_REG { PARAM_VALUE.NUM_REG } {
	# Procedure called to validate NUM_REG
	return true
}

proc update_PARAM_VALUE.PHY_ADDR { PARAM_VALUE.PHY_ADDR } {
	# Procedure called to update PHY_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PHY_ADDR { PARAM_VALUE.PHY_ADDR } {
	# Procedure called to validate PHY_ADDR
	return true
}

proc update_PARAM_VALUE.SLAVE_ID { PARAM_VALUE.SLAVE_ID } {
	# Procedure called to update SLAVE_ID when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SLAVE_ID { PARAM_VALUE.SLAVE_ID } {
	# Procedure called to validate SLAVE_ID
	return true
}


proc update_MODELPARAM_VALUE.PHY_ADDR { MODELPARAM_VALUE.PHY_ADDR PARAM_VALUE.PHY_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PHY_ADDR}] ${MODELPARAM_VALUE.PHY_ADDR}
}

proc update_MODELPARAM_VALUE.SLAVE_ID { MODELPARAM_VALUE.SLAVE_ID PARAM_VALUE.SLAVE_ID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SLAVE_ID}] ${MODELPARAM_VALUE.SLAVE_ID}
}

proc update_MODELPARAM_VALUE.NUM_REG { MODELPARAM_VALUE.NUM_REG PARAM_VALUE.NUM_REG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_REG}] ${MODELPARAM_VALUE.NUM_REG}
}

