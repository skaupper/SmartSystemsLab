#!/usr/bin/env bash

set -euo pipefail

QSYS_DESIGN=../HPSPlatform.qsys

echo "----------------- Entered file $0 ---------------------------------------------------"

qsys-generate --synthesis=VERILOG $QSYS_DESIGN

echo "----------------- Leaving file $0 ---------------------------------------------------"
