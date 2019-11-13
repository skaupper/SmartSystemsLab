#!/bin/bash

#####
# NOTE: This file needs to be called like "source initbuildenv.sh"
#####

unset LD_LIBRARY_PATH
export KERNEL_SRC=/opt/poky/2.6.4/sysroots/cortexa9hf-neon-poky-linux-gnueabi/usr/src/kernel/
export LDFLAGS=""

source /opt/poky/2.6.4/environment-setup-cortexa9hf-neon-poky-linux-gnueabi

export DEPLOYSSH=root@cyclone5
export DEPLOYSSH=root@192.168.0.106
export DEPLOYSSHPATH=/home/root/
