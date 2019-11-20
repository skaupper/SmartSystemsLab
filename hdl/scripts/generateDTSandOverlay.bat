@echo off
echo  on
echo Running %~nx0
set _BAT_ROOT=%~dp0
set _BAT_ROOT=%_BAT_ROOT:\=/%
set CHERE_INVOKING=1
set HOME=.


set "OUTPUT_DTS=output/socfpga.dts"
set "OUTPUT_DTSO=output/socfpga.dtso"
set "BOOTARGS=earlyprintk"
set "STDOUTPATH=serial0:115200n8"

call %EDS_SHELL% sopc2dts -v --input ../HPSPlatform.sopcinfo --output %OUTPUT_DTS% --type dts --board ./input/soc_system_board_info.xml --board ./input/hps_common_board_info.xml --bridge-removal all --bridge-ranges bridge --clocks

:: generate dtso from dts
call %EDS_SHELL% adaptDTS.sh


:: sopc2dts --input ../HPSPlatform.sopcinfo\
::   --output socfpga.dtso\
::   --type dts\
::   --bridge-removal all\
::   --bridge-ranges bridge\
::   --clocks\
::   --pov-type overlay\
::   --pov hps_0_bridges\
  
  
:: sopc2dts --input ../HPSPlatform.sopcinfo\
::   --output socfpga.dts\
::   --type dts\
::   --board soc_system_board_info.xml\
::   --board hps_common_board_info.xml\
::   --bridge-removal all\
::   --clocks




