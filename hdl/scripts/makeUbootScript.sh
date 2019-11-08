#!/usr/bin/env bash

mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n u-boot -d ./input/u-boot.script ./output/boot.scr
