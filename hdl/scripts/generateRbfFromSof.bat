@echo off
echo Running %~nx0
set _BAT_ROOT=%~dp0
set _BAT_ROOT=%_BAT_ROOT:\=/%
set CHERE_INVOKING=1
set HOME=.

set "RBF_NAME=./output/socfpga.rbf"

:: convert sof to uncompressed rbf
call %EDS_SHELL% quartus_cpf -c "../output_files/top.sof" %RBF_NAME%





