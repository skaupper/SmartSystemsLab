onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tbhdc1000/clk
add wave -noupdate /tbhdc1000/nRst
add wave -noupdate /tbhdc1000/avs_s0_address
add wave -noupdate /tbhdc1000/avs_s0_read
add wave -noupdate /tbhdc1000/avs_s0_readdata
add wave -noupdate /tbhdc1000/avs_s0_write
add wave -noupdate /tbhdc1000/avs_s0_writedata
add wave -noupdate /tbhdc1000/Dut/msTick
add wave -noupdate /tbhdc1000/Dut/reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {26562618 ps}
