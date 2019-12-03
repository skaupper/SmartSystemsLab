@echo off
echo Running %~nx0
set _BAT_ROOT=%~dp0
set _BAT_ROOT=%_BAT_ROOT:\=/%
set CHERE_INVOKING=1
set HOME=.


call %EDS_SHELL% mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n u-boot -d ./input/u-boot.script ./output/boot.scr
