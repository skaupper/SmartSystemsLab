#!/usr/bin/env bash

set -euo pipefail

echo "----------------- Entered file $0 ---------------------------------------------------"
source ./defineFilenames.sh

qsys-generate --synthesis=VERILOG $QSYS_DESIGN

echo "----------------- Leaving file $0 ---------------------------------------------------"
