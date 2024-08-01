#!/bin/bash

SRC_DIR=src
BUILD_DIR=build
TOOLCHAIN_DIR=/opt/gcc-arm-none-eabi-9.3.1/bin

CC=${TOOLCHAIN_DIR}/arm-none-eabi-gcc
ASM=${TOOLCHAIN_DIR}/arm-none-eabi-as
LINKER=${TOOLCHAIN_DIR}/arm-none-eabi-ld
OBJCOPY=${TOOLCHAIN_DIR}/arm-none-eabi-objcopy

mkdir -p ${BUILD_DIR}

${ASM} -o ${BUILD_DIR}/startup.o ${SRC_DIR}/startup.s

cd ${BUILD_DIR} && ${LINKER} -T ../${SRC_DIR}/linkscript.ld \
                      -o hang.elf \
                      startup.o \
                && cd ..

${OBJCOPY} -O binary ${BUILD_DIR}/hang.elf ${BUILD_DIR}/hang.bin

