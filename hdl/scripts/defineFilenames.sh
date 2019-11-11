#!/bin/bash

OUTPUT_DTS=./output/socfpga.dts
OUTPUT_DTSO=./output/socfpga.dtso
OUTPUT_DTBO=./output/socfpga.dtbo
OUTPUT_DTB=./output/socfpga.dtb

QSYS_DESIGN=../HPSPlatform.qsys
QUARTUS_DESIGN=../top.qpf

BOOTARGS=earlyprintk
STDOUTPATH=serial0:115200n8

RBF_NAME=./output/socfpga.rbf
