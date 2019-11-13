#!/usr/bin/env bash

HEADER_NAME=hps_0.h

sopc-create-header-files '../HPSPlatform.sopcinfo' --single "./output/$HEADER_NAME" --module hps_0
