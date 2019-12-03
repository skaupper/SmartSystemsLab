#----------------------------------*-tcl-*-
do Comp.do

echo "Sim: load design"
set unit tbHdc1000
vsim -novopt -wlfdeleteonquit \
      work.${unit}(Bhv)

set tb    ${unit}
set dut   ${tb}/DUT

echo "Sim: load wave-file(s)"
catch {do wave.do}

echo "Sim: log signals"
log -r /*

echo "Sim: run ..."
run 100 us

catch {do wave-restore.do}
