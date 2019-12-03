onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group TB -radix hexadecimal /tbhdc1000/avs_s0_address
add wave -noupdate -expand -group TB /tbhdc1000/avs_s0_read
add wave -noupdate -expand -group TB -radix hexadecimal /tbhdc1000/avs_s0_readdata
add wave -noupdate -expand -group TB /tbhdc1000/avs_s0_write
add wave -noupdate -expand -group TB -radix hexadecimal /tbhdc1000/avs_s0_writedata
add wave -noupdate -expand -group TB -radix hexadecimal /tbhdc1000/avm_m0_address
add wave -noupdate -expand -group TB /tbhdc1000/avm_m0_read
add wave -noupdate -expand -group TB -radix hexadecimal /tbhdc1000/avm_m0_readdata
add wave -noupdate -expand -group TB /tbhdc1000/avm_m0_write
add wave -noupdate -expand -group TB /tbhdc1000/avm_m0_waitrequest
add wave -noupdate -expand -group TB -radix hexadecimal /tbhdc1000/avm_m0_writedata
add wave -noupdate -expand -group TB /tbhdc1000/clk
add wave -noupdate -expand -group TB /tbhdc1000/nRst
add wave -noupdate -expand -group TB /tbhdc1000/hdcRdy
add wave -noupdate -expand -group TB /tbhdc1000/sda_in
add wave -noupdate -expand -group TB /tbhdc1000/scl_in
add wave -noupdate -expand -group TB /tbhdc1000/sda_oe
add wave -noupdate -expand -group TB /tbhdc1000/scl_oe
add wave -noupdate -expand -group Dut /tbhdc1000/Dut/iClk
add wave -noupdate -expand -group Dut /tbhdc1000/Dut/inRst
add wave -noupdate -expand -group Dut /tbhdc1000/Dut/avs_s0_address
add wave -noupdate -expand -group Dut /tbhdc1000/Dut/avs_s0_read
add wave -noupdate -expand -group Dut -radix hexadecimal /tbhdc1000/Dut/avs_s0_readdata
add wave -noupdate -expand -group Dut /tbhdc1000/Dut/avs_s0_write
add wave -noupdate -expand -group Dut -radix hexadecimal /tbhdc1000/Dut/avs_s0_writedata
add wave -noupdate -expand -group Dut -radix hexadecimal /tbhdc1000/Dut/avm_m0_address
add wave -noupdate -expand -group Dut /tbhdc1000/Dut/avm_m0_read
add wave -noupdate -expand -group Dut -radix hexadecimal /tbhdc1000/Dut/avm_m0_readdata
add wave -noupdate -expand -group Dut /tbhdc1000/Dut/avm_m0_write
add wave -noupdate -expand -group Dut -radix hexadecimal /tbhdc1000/Dut/avm_m0_writedata
add wave -noupdate -expand -group Dut /tbhdc1000/Dut/avm_m0_waitrequest
add wave -noupdate -expand -group Dut /tbhdc1000/Dut/iHdcRdy
add wave -noupdate -expand -group Dut /tbhdc1000/Dut/msTick
add wave -noupdate -expand -group Dut -childformat {{/tbhdc1000/Dut/reg.readdata -radix hexadecimal} {/tbhdc1000/Dut/reg.counter -radix unsigned} {/tbhdc1000/Dut/reg.timestamp -radix unsigned}} -expand -subitemconfig {/tbhdc1000/Dut/reg.readdata {-radix hexadecimal} /tbhdc1000/Dut/reg.counter {-radix unsigned} /tbhdc1000/Dut/reg.timestamp {-radix unsigned}} /tbhdc1000/Dut/reg
add wave -noupdate -expand -group Dut /tbhdc1000/Dut/nxR
add wave -noupdate -expand -group Dut /tbhdc1000/Dut/hdcRdy
add wave -noupdate -expand -group Dut /tbhdc1000/Dut/hdcRdySync
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {325000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 277
configure wave -valuecolwidth 97
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1976696 ps}
