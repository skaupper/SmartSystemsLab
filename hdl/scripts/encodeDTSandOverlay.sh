#!/usr/bin/env bash

set -euo pipefail

echo "----------------- Entered file $0 ---------------------------------------------------"
source ./defineFilenames.sh

dtc -I dts -O dtb -o "$OUTPUT_DTBO" "$OUTPUT_DTSO"
dtc -I dts -O dtb -o "$OUTPUT_DTB" -@ "$OUTPUT_DTS"

# decompile cmd
# dtc -I dtb -O dts -o "overlayDECOMPILED.dtso"  "overlay.dtbo"

echo "----------------- Leaving file $0 ---------------------------------------------------"
