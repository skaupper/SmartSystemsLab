
#----------------------------------*-tcl-*-

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
echo ## pkgGlobal
vlib work
myvcom Global-p.vhd
myvcom StrobeGen-ea.vhd
myvcom apds9301-ea.vhd
myvcom tbApds9301-ea.vhd