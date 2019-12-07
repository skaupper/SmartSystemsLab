onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tbapds9301/avs_s0_address
add wave -noupdate /tbapds9301/avs_s0_read
add wave -noupdate -radix hexadecimal /tbapds9301/avs_s0_readdata
add wave -noupdate /tbapds9301/avs_s0_write
add wave -noupdate -radix hexadecimal /tbapds9301/avs_s0_writedata
add wave -noupdate -radix hexadecimal /tbapds9301/avm_m0_address
add wave -noupdate /tbapds9301/avm_m0_read
add wave -noupdate -radix hexadecimal /tbapds9301/avm_m0_readdata
add wave -noupdate /tbapds9301/avm_m0_write
add wave -noupdate /tbapds9301/avm_m0_waitrequest
add wave -noupdate -radix hexadecimal /tbapds9301/avm_m0_writedata
add wave -noupdate /tbapds9301/clk
add wave -noupdate /tbapds9301/nRst
add wave -noupdate /tbapds9301/nApdsInterrupt
add wave -noupdate -childformat {{/tbapds9301/Dut/reg.readdata -radix hexadecimal} {/tbapds9301/Dut/reg.timestamp -radix hexadecimal}} -expand -subitemconfig {/tbapds9301/Dut/reg.readdata {-radix hexadecimal} /tbapds9301/Dut/reg.reg {-childformat {{/tbapds9301/Dut/reg.reg.timestamp -radix hexadecimal} {/tbapds9301/Dut/reg.reg.light -radix hexadecimal}} -expand} /tbapds9301/Dut/reg.reg.timestamp {-radix hexadecimal} /tbapds9301/Dut/reg.reg.light {-radix hexadecimal} /tbapds9301/Dut/reg.shadowReg {-childformat {{/tbapds9301/Dut/reg.shadowReg.timestamp -radix hexadecimal} {/tbapds9301/Dut/reg.shadowReg.light -radix hexadecimal}} -expand} /tbapds9301/Dut/reg.shadowReg.timestamp {-radix hexadecimal} /tbapds9301/Dut/reg.shadowReg.light {-radix hexadecimal} /tbapds9301/Dut/reg.avm {-childformat {{/tbapds9301/Dut/reg.avm.addr -radix hexadecimal} {/tbapds9301/Dut/reg.avm.wData -radix hexadecimal}} -expand} /tbapds9301/Dut/reg.avm.addr {-radix hexadecimal} /tbapds9301/Dut/reg.avm.wData {-radix hexadecimal} /tbapds9301/Dut/reg.timestamp {-radix hexadecimal}} /tbapds9301/Dut/reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {803388 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 256
configure wave -valuecolwidth 130
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
WaveRestoreZoom {0 ps} {1029276 ps}
