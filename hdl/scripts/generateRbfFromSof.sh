#!/usr/bin/env bash

set -euo pipefail

echo "----------------- Entered file $0 ---------------------------------------------------"
source ./defineFilenames.sh

# Convert SOF to uncompressed RBF
quartus_cpf -c '../output_files/top.sof' "$RBF_NAME"

echo "----------------- Leaving file $0 ---------------------------------------------------"
