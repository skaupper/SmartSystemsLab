@echo off
echo Running %~nx0
set _BAT_ROOT=%~dp0
set _BAT_ROOT=%_BAT_ROOT:\=/%
set CHERE_INVOKING=1
set HOME=.


set "DTSO_NAME=./output/socfpga.dtso"
set "DTBO_NAME=./output/socfpga.dtbo"
set "DTS_NAME=./output/socfpga.dts"
set "DTB_NAME=./output/socfpga.dtb"

call %EDS_SHELL% dtc -I dts -O dtb -o '%DTBO_NAME%' '%DTSO_NAME%'

call %EDS_SHELL% dtc -I dts -O dtb -o '%DTB_NAME%' -@ '%DTS_NAME%'

:: decompile cmd
:: dtc -I dtb -O dts -o "overlayDECOMPILED.dtso"  "overlay.dtbo"



