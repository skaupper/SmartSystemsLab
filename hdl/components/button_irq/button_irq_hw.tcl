# TCL File Generated by Component Editor 19.1
# Sun Dec 29 18:49:52 CET 2019
# DO NOT MODIFY


# 
# button_irq "button_irq" v1.0
# Michael Wurm 2019.12.29.18:49:52
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module button_irq
# 
set_module_property DESCRIPTION ""
set_module_property NAME button_irq
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR "Michael Wurm"
set_module_property DISPLAY_NAME button_irq
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL button_irq
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file Global-p.vhd VHDL PATH ../apds9301/Global-p.vhd
add_fileset_file StrobeGen-ea.vhd VHDL PATH ../apds9301/StrobeGen-ea.vhd
add_fileset_file button_irq.vhd VHDL PATH button_irq.vhd TOP_LEVEL_FILE


# 
# parameters
# 
add_parameter gClkFrequency NATURAL 50000000
set_parameter_property gClkFrequency DEFAULT_VALUE 50000000
set_parameter_property gClkFrequency DISPLAY_NAME gClkFrequency
set_parameter_property gClkFrequency TYPE NATURAL
set_parameter_property gClkFrequency UNITS None
set_parameter_property gClkFrequency ALLOWED_RANGES 0:2147483647
set_parameter_property gClkFrequency HDL_PARAMETER true
add_parameter gI2cFrequency NATURAL 400000
set_parameter_property gI2cFrequency DEFAULT_VALUE 400000
set_parameter_property gI2cFrequency DISPLAY_NAME gI2cFrequency
set_parameter_property gI2cFrequency TYPE NATURAL
set_parameter_property gI2cFrequency UNITS None
set_parameter_property gI2cFrequency ALLOWED_RANGES 0:2147483647
set_parameter_property gI2cFrequency HDL_PARAMETER true


# 
# display items
# 


# 
# connection point s0
# 
add_interface s0 avalon end
set_interface_property s0 addressUnits WORDS
set_interface_property s0 associatedClock clk_i
set_interface_property s0 associatedReset rstn_i
set_interface_property s0 bitsPerSymbol 8
set_interface_property s0 burstOnBurstBoundariesOnly false
set_interface_property s0 burstcountUnits WORDS
set_interface_property s0 explicitAddressSpan 0
set_interface_property s0 holdTime 0
set_interface_property s0 linewrapBursts false
set_interface_property s0 maximumPendingReadTransactions 0
set_interface_property s0 maximumPendingWriteTransactions 0
set_interface_property s0 readLatency 0
set_interface_property s0 readWaitTime 1
set_interface_property s0 setupTime 0
set_interface_property s0 timingUnits Cycles
set_interface_property s0 writeWaitTime 0
set_interface_property s0 ENABLED true
set_interface_property s0 EXPORT_OF ""
set_interface_property s0 PORT_NAME_MAP ""
set_interface_property s0 CMSIS_SVD_VARIABLES ""
set_interface_property s0 SVD_ADDRESS_GROUP ""

add_interface_port s0 avs_s0_address address Input 2
add_interface_port s0 avs_s0_read read Input 1
add_interface_port s0 avs_s0_readdata readdata Output 32
add_interface_port s0 avs_s0_write write Input 1
add_interface_port s0 avs_s0_writedata writedata Input 32
set_interface_assignment s0 embeddedsw.configuration.isFlash 0
set_interface_assignment s0 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment s0 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment s0 embeddedsw.configuration.isPrintableDevice 0


# 
# connection point clk_i
# 
add_interface clk_i clock end
set_interface_property clk_i clockRate 0
set_interface_property clk_i ENABLED true
set_interface_property clk_i EXPORT_OF ""
set_interface_property clk_i PORT_NAME_MAP ""
set_interface_property clk_i CMSIS_SVD_VARIABLES ""
set_interface_property clk_i SVD_ADDRESS_GROUP ""

add_interface_port clk_i clk_i clk Input 1


# 
# connection point rstn_i
# 
add_interface rstn_i reset end
set_interface_property rstn_i associatedClock clk_i
set_interface_property rstn_i synchronousEdges DEASSERT
set_interface_property rstn_i ENABLED true
set_interface_property rstn_i EXPORT_OF ""
set_interface_property rstn_i PORT_NAME_MAP ""
set_interface_property rstn_i CMSIS_SVD_VARIABLES ""
set_interface_property rstn_i SVD_ADDRESS_GROUP ""

add_interface_port rstn_i rst_i reset_n Input 1


# 
# connection point interrupt_o
# 
add_interface interrupt_o interrupt end
set_interface_property interrupt_o associatedAddressablePoint s0
set_interface_property interrupt_o associatedClock clk_i
set_interface_property interrupt_o associatedReset rstn_i
set_interface_property interrupt_o bridgedReceiverOffset 0
set_interface_property interrupt_o bridgesToReceiver ""
set_interface_property interrupt_o ENABLED true
set_interface_property interrupt_o EXPORT_OF ""
set_interface_property interrupt_o PORT_NAME_MAP ""
set_interface_property interrupt_o CMSIS_SVD_VARIABLES ""
set_interface_property interrupt_o SVD_ADDRESS_GROUP ""

add_interface_port interrupt_o interrupt_o irq Output 1

