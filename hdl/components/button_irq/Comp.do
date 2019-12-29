##############
#
# This script must be called in this directory.
# Call it like:
#    vsim -do Comp.do -c
#
##############

eval onerror {quit -f}
eval onbreak {quit -f}

#-------------------------------------------
proc myvcom {filename} {
  if {[file exists ${filename}] == 1} {
    puts "## vcom $filename"
    vcom -93 -novopt -quiet ${filename} -work work
  } else {
    puts "## WARNING: File not found: ${filename}"
  }
}
#-------------------------------------------

vlib work
myvcom ../apds9301/Global-p.vhd
myvcom ../apds9301/StrobeGen-ea.vhd
myvcom button_irq.vhd

eval quit -f
