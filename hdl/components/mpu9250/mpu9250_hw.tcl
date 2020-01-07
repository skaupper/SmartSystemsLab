# TCL File Generated by Component Editor 18.1
# Tue Dec 17 16:01:35 CET 2019
# DO NOT MODIFY


# 
# mpu9250 "mpu9250" v1.0
#  2019.12.17.16:01:35
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module mpu9250
# 
set_module_property DESCRIPTION ""
set_module_property NAME mpu9250
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME mpu9250
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL mpu9250
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file mpu9250-ea.vhd VHDL PATH mpu9250-ea.vhd TOP_LEVEL_FILE
add_fileset_file Global-p.vhd VHDL PATH Global-p.vhd
add_fileset_file StrobeGen-ea.vhd VHDL PATH StrobeGen-ea.vhd
add_fileset_file spi_master.vhd VHDL PATH spi_master.vhd
add_fileset_file ram.vhd VHDL PATH ram/ram.vhd


# 
# parameters
# 
add_parameter gClkFrequency NATURAL 50000000 ""
set_parameter_property gClkFrequency DEFAULT_VALUE 50000000
set_parameter_property gClkFrequency DISPLAY_NAME gClkFrequency
set_parameter_property gClkFrequency TYPE NATURAL
set_parameter_property gClkFrequency UNITS None
set_parameter_property gClkFrequency ALLOWED_RANGES 0:2147483647
set_parameter_property gClkFrequency DESCRIPTION ""
set_parameter_property gClkFrequency HDL_PARAMETER true
add_parameter gPreShockCount NATURAL 256
set_parameter_property gPreShockCount DEFAULT_VALUE 256
set_parameter_property gPreShockCount DISPLAY_NAME gPreShockCount
set_parameter_property gPreShockCount TYPE NATURAL
set_parameter_property gPreShockCount UNITS None
set_parameter_property gPreShockCount ALLOWED_RANGES 0:2147483647
set_parameter_property gPreShockCount HDL_PARAMETER true


# 
# module assignments
# 
set_module_assignment embeddedsw.dts.group sensor
set_module_assignment embeddedsw.dts.name mpu9250
set_module_assignment embeddedsw.dts.vendor goe


# 
# display items
# 


# 
# connection point clk
# 
add_interface clk clock end
set_interface_property clk clockRate 0
set_interface_property clk ENABLED true
set_interface_property clk EXPORT_OF ""
set_interface_property clk PORT_NAME_MAP ""
set_interface_property clk CMSIS_SVD_VARIABLES ""
set_interface_property clk SVD_ADDRESS_GROUP ""

add_interface_port clk iClk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clk
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset inRst reset_n Input 1


# 
# connection point mpuInt
# 
add_interface mpuInt interrupt start
set_interface_property mpuInt associatedAddressablePoint ""
set_interface_property mpuInt associatedClock clk
set_interface_property mpuInt associatedReset reset
set_interface_property mpuInt irqScheme INDIVIDUAL_REQUESTS
set_interface_property mpuInt ENABLED true
set_interface_property mpuInt EXPORT_OF ""
set_interface_property mpuInt PORT_NAME_MAP ""
set_interface_property mpuInt CMSIS_SVD_VARIABLES ""
set_interface_property mpuInt SVD_ADDRESS_GROUP ""

add_interface_port mpuInt inMpuInt irq_n Input 1


# 
# connection point spi_serial
# 
add_interface spi_serial conduit end
set_interface_property spi_serial associatedClock clk
set_interface_property spi_serial associatedReset reset
set_interface_property spi_serial ENABLED true
set_interface_property spi_serial EXPORT_OF ""
set_interface_property spi_serial PORT_NAME_MAP ""
set_interface_property spi_serial CMSIS_SVD_VARIABLES ""
set_interface_property spi_serial SVD_ADDRESS_GROUP ""

add_interface_port spi_serial sclk sclk Output 1
add_interface_port spi_serial mosi mosi Output 1
add_interface_port spi_serial miso miso Input 1
add_interface_port spi_serial ss_n ss_n Output 1


# 
# connection point irq
# 
add_interface irq interrupt end
set_interface_property irq associatedAddressablePoint ""
set_interface_property irq associatedClock clk
set_interface_property irq associatedReset reset
set_interface_property irq bridgedReceiverOffset ""
set_interface_property irq bridgesToReceiver ""
set_interface_property irq ENABLED true
set_interface_property irq EXPORT_OF ""
set_interface_property irq PORT_NAME_MAP ""
set_interface_property irq CMSIS_SVD_VARIABLES ""
set_interface_property irq SVD_ADDRESS_GROUP ""

add_interface_port irq irq_irq irq Output 1


# 
# connection point s0
# 
add_interface s0 avalon end
set_interface_property s0 addressUnits WORDS
set_interface_property s0 associatedClock clk
set_interface_property s0 associatedReset reset
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

add_interface_port s0 avs_s0_address address Input 4
add_interface_port s0 avs_s0_read read Input 1
add_interface_port s0 avs_s0_readdata readdata Output 32
add_interface_port s0 avs_s0_write write Input 1
add_interface_port s0 avs_s0_writedata writedata Input 32
set_interface_assignment s0 embeddedsw.configuration.isFlash 0
set_interface_assignment s0 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment s0 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment s0 embeddedsw.configuration.isPrintableDevice 0

