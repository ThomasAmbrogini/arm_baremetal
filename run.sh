#!/bin/bash

BUILD_DIR=build
EXECUTABLE_NAME=$1
EXECUTABLE_PATH=${BUILD_DIR}/${EXECUTABLE_NAME}

qemu-system-arm -M vexpress-a9 \
                -m 32M \
                -no-reboot \
                -nographic \
                -monitor telnet:127.0.0.1:1234,server,nowait \
                -kernel ${EXECUTABLE_PATH} \
