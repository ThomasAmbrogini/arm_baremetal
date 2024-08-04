#!/bin/bash

BUILD_DIR=build
EXECUTABLE_NAME=bare-arm.uimg
EXECUTABLE_PATH=${BUILD_DIR}/${EXECUTABLE_NAME}

qemu-system-arm -M vexpress-a9 \
                -m 512M \
                -no-reboot \
                -nographic \
                -monitor telnet:127.0.0.1:1234,server,nowait \
                -kernel u-boot/u-boot \
                -sd ${BUILD_DIR}/sdcard.img \

