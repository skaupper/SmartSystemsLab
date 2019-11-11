#!/usr/bin/env bash

set -euo pipefail

echo "----------------- Entered file $0 ---------------------------------------------------"

RBF_NAME=./output/socfpga.rbf

# Convert sof to uncompressed rbf
quartus_cpf -c '../output_files/template.sof' "$RBF_NAME"

echo "----------------- Leaving file $0 ---------------------------------------------------"
