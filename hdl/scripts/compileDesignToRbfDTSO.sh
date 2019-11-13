#!/usr/bin/env bash

set -euo pipefail


QSYS_DESIGN=../HPSPlatform.qsys
QUARTUS_DESIGN=../top.qpf


# !!! if Qsys does not complete, comment the next
#     line and generate the QSYS design using the GUI !!!
./regenerateQsysDesign.sh



# quartus_sh --flow compile $QUARTUS_DESIGN

echo "Before map"
quartus_map --read_settings_files=on --write_settings_files=off $QUARTUS_DESIGN -c top

echo "Before cdb"
quartus_cdb --merge --read_settings_files=off --write_settings_files=off $QUARTUS_DESIGN -c top

echo "Before fit"
quartus_fit --read_settings_files=off --write_settings_files=off $QUARTUS_DESIGN -c top

echo "Before asm"
quartus_asm --read_settings_files=off --write_settings_files=off $QUARTUS_DESIGN -c top

echo "Generate DTS and Overlay"
./generateDTSandOverlay.sh

echo "Generate RBF from SOF"
./generateRbfFromSof.sh
