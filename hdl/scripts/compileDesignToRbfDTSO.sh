#!/usr/bin/env bash

set -euo pipefail

QSYS_DESIGN=../HPSPlatform.qsys
QUARTUS_DESIGN=../template.qpf

echo "----------------- Entered file $0 ---------------------------------------------------"

# NOTE: If QSYS does not complete, comment the next
#       line and generate the QSYS design using the GUI.
./regenerateQsysDesign.sh

quartus_sh --flow compile $QUARTUS_DESIGN

quartus_map --read_settings_files=on --write_settings_files=off $QUARTUS_DESIGN -c template
quartus_cdb --merge --read_settings_files=off --write_settings_files=off $QUARTUS_DESIGN -c template
quartus_fit --read_settings_files=off --write_settings_files=off $QUARTUS_DESIGN -c template
quartus_asm --read_settings_files=off --write_settings_files=off $QUARTUS_DESIGN -c template

./generateDTSandOverlay.sh
./generateRbfFromSof.sh
./encodeDTSandOverlay.sh

echo "----------------- Leaving file $0 ---------------------------------------------------"
