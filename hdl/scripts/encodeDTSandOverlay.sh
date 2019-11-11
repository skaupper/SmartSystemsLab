#!/usr/bin/env bash

set -euo pipefail

echo "----------------- Entered file $0 ---------------------------------------------------"

DTSO_NAME=./output/socfpga.dtso
DTBO_NAME=./output/socfpga.dtbo
DTS_NAME=./output/socfpga.dts
DTB_NAME=./output/socfpga.dtb

dtc -I dts -O dtb -o "$DTBO_NAME" "$DTSO_NAME"
dtc -I dts -O dtb -o "$DTB_NAME" -@ "$DTS_NAME"

# decompile cmd
# dtc -I dtb -O dts -o "overlayDECOMPILED.dtso"  "overlay.dtbo"

echo "----------------- Leaving file $0 ---------------------------------------------------"
