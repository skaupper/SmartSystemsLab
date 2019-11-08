#!/usr/bin/env bash

QSYS_DESIGN=../HPSPlatform.qsys

qsys-generate --synthesis=VERILOG $QSYS_DESIGN
