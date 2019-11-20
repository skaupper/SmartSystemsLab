@echo off
echo Running %~nx0
set _BAT_ROOT=%~dp0
set _BAT_ROOT=%_BAT_ROOT:\=/%
set CHERE_INVOKING=1
set HOME=.


set "HEADER_NAME=hps_0.h"

call %EDS_SHELL% sopc-create-header-files '../HPSPlatform.sopcinfo' --single './output/%HEADER_NAME%' --module hps_0


