onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider TB
add wave -noupdate -radix hexadecimal /tbmpu9250/avs_s0_address
add wave -noupdate /tbmpu9250/avs_s0_read
add wave -noupdate -radix hexadecimal /tbmpu9250/avs_s0_readdata
add wave -noupdate /tbmpu9250/avs_s0_write
add wave -noupdate -radix hexadecimal /tbmpu9250/avs_s0_writedata
add wave -noupdate -radix hexadecimal /tbmpu9250/avm_m0_address
add wave -noupdate /tbmpu9250/avm_m0_read
add wave -noupdate -radix hexadecimal /tbmpu9250/avm_m0_readdata
add wave -noupdate /tbmpu9250/avm_m0_write
add wave -noupdate /tbmpu9250/avm_m0_waitrequest
add wave -noupdate -radix hexadecimal /tbmpu9250/avm_m0_writedata
add wave -noupdate /tbmpu9250/clk
add wave -noupdate /tbmpu9250/nRst
add wave -noupdate /tbmpu9250/spiTxReady
add wave -noupdate /tbmpu9250/mpuInt
add wave -noupdate -divider DUT
add wave -noupdate /tbmpu9250/Dut/gClkFrequency
add wave -noupdate /tbmpu9250/Dut/iClk
add wave -noupdate /tbmpu9250/Dut/inRst
add wave -noupdate -radix hexadecimal /tbmpu9250/Dut/avs_s0_address
add wave -noupdate /tbmpu9250/Dut/avs_s0_read
add wave -noupdate -radix hexadecimal /tbmpu9250/Dut/avs_s0_readdata
add wave -noupdate /tbmpu9250/Dut/avs_s0_write
add wave -noupdate -radix hexadecimal /tbmpu9250/Dut/avs_s0_writedata
add wave -noupdate -radix hexadecimal /tbmpu9250/Dut/avm_m0_address
add wave -noupdate /tbmpu9250/Dut/avm_m0_read
add wave -noupdate -radix hexadecimal /tbmpu9250/Dut/avm_m0_readdata
add wave -noupdate -radix hexadecimal /tbmpu9250/Dut/avm_m0_write
add wave -noupdate /tbmpu9250/Dut/avm_m0_writedata
add wave -noupdate /tbmpu9250/Dut/avm_m0_waitrequest
add wave -noupdate /tbmpu9250/Dut/iSpiTxReady
add wave -noupdate /tbmpu9250/Dut/iMpuInt
add wave -noupdate /tbmpu9250/Dut/msTick
add wave -noupdate -childformat {{/tbmpu9250/Dut/reg.readdata -radix hexadecimal} {/tbmpu9250/Dut/reg.timestamp -radix hexadecimal}} -expand -subitemconfig {/tbmpu9250/Dut/reg.readdata {-radix hexadecimal} /tbmpu9250/Dut/reg.reg {-childformat {{/tbmpu9250/Dut/reg.reg.timestamp -radix hexadecimal}}} /tbmpu9250/Dut/reg.reg.timestamp {-radix hexadecimal} /tbmpu9250/Dut/reg.reg.data {-childformat {{/tbmpu9250/Dut/reg.reg.data(0) -radix hexadecimal} {/tbmpu9250/Dut/reg.reg.data(1) -radix hexadecimal} {/tbmpu9250/Dut/reg.reg.data(2) -radix hexadecimal} {/tbmpu9250/Dut/reg.reg.data(3) -radix hexadecimal} {/tbmpu9250/Dut/reg.reg.data(4) -radix hexadecimal} {/tbmpu9250/Dut/reg.reg.data(5) -radix hexadecimal} {/tbmpu9250/Dut/reg.reg.data(6) -radix hexadecimal} {/tbmpu9250/Dut/reg.reg.data(7) -radix hexadecimal} {/tbmpu9250/Dut/reg.reg.data(8) -radix hexadecimal} {/tbmpu9250/Dut/reg.reg.data(9) -radix hexadecimal}} -expand} /tbmpu9250/Dut/reg.reg.data(0) {-radix hexadecimal} /tbmpu9250/Dut/reg.reg.data(1) {-radix hexadecimal} /tbmpu9250/Dut/reg.reg.data(2) {-radix hexadecimal} /tbmpu9250/Dut/reg.reg.data(3) {-radix hexadecimal} /tbmpu9250/Dut/reg.reg.data(4) {-radix hexadecimal} /tbmpu9250/Dut/reg.reg.data(5) {-radix hexadecimal} /tbmpu9250/Dut/reg.reg.data(6) {-radix hexadecimal} /tbmpu9250/Dut/reg.reg.data(7) {-radix hexadecimal} /tbmpu9250/Dut/reg.reg.data(8) {-radix hexadecimal} /tbmpu9250/Dut/reg.reg.data(9) {-radix hexadecimal} /tbmpu9250/Dut/reg.shadowReg {-childformat {{/tbmpu9250/Dut/reg.shadowReg.timestamp -radix hexadecimal}}} /tbmpu9250/Dut/reg.shadowReg.timestamp {-radix hexadecimal} /tbmpu9250/Dut/reg.shadowReg.data {-childformat {{/tbmpu9250/Dut/reg.shadowReg.data(0) -radix hexadecimal} {/tbmpu9250/Dut/reg.shadowReg.data(1) -radix hexadecimal} {/tbmpu9250/Dut/reg.shadowReg.data(2) -radix hexadecimal} {/tbmpu9250/Dut/reg.shadowReg.data(3) -radix hexadecimal} {/tbmpu9250/Dut/reg.shadowReg.data(4) -radix hexadecimal} {/tbmpu9250/Dut/reg.shadowReg.data(5) -radix hexadecimal} {/tbmpu9250/Dut/reg.shadowReg.data(6) -radix hexadecimal} {/tbmpu9250/Dut/reg.shadowReg.data(7) -radix hexadecimal} {/tbmpu9250/Dut/reg.shadowReg.data(8) -radix hexadecimal} {/tbmpu9250/Dut/reg.shadowReg.data(9) -radix hexadecimal}} -expand} /tbmpu9250/Dut/reg.shadowReg.data(0) {-radix hexadecimal} /tbmpu9250/Dut/reg.shadowReg.data(1) {-radix hexadecimal} /tbmpu9250/Dut/reg.shadowReg.data(2) {-radix hexadecimal} /tbmpu9250/Dut/reg.shadowReg.data(3) {-radix hexadecimal} /tbmpu9250/Dut/reg.shadowReg.data(4) {-radix hexadecimal} /tbmpu9250/Dut/reg.shadowReg.data(5) {-radix hexadecimal} /tbmpu9250/Dut/reg.shadowReg.data(6) {-radix hexadecimal} /tbmpu9250/Dut/reg.shadowReg.data(7) {-radix hexadecimal} /tbmpu9250/Dut/reg.shadowReg.data(8) {-radix hexadecimal} /tbmpu9250/Dut/reg.shadowReg.data(9) {-radix hexadecimal} /tbmpu9250/Dut/reg.avm {-childformat {{/tbmpu9250/Dut/reg.avm.addr -radix hexadecimal} {/tbmpu9250/Dut/reg.avm.wData -radix hexadecimal}}} /tbmpu9250/Dut/reg.avm.addr {-radix hexadecimal} /tbmpu9250/Dut/reg.avm.wData {-radix hexadecimal} /tbmpu9250/Dut/reg.timestamp {-radix hexadecimal}} /tbmpu9250/Dut/reg
add wave -noupdate /tbmpu9250/Dut/nxR
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {219705 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 264
configure wave -valuecolwidth 60
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
WaveRestoreZoom {0 ps} {1045956 ps}
