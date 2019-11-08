#!/usr/bin/env bash

RBF_NAME=./output/socfpga.rbf

quartus_cpf -c '../output_files/top.sof' "$RBF_NAME"
