#!/bin/bash

SRC_DIR=src
BUILD_DIR=build
INFO_DIR=${BUILD_DIR}/info
TOOLCHAIN_DIR=/opt/gcc-arm-none-eabi-9.3.1/bin

CC=${TOOLCHAIN_DIR}/arm-none-eabi-gcc
ASM=${TOOLCHAIN_DIR}/arm-none-eabi-as
LINKER=${TOOLCHAIN_DIR}/arm-none-eabi-ld
OBJCOPY=${TOOLCHAIN_DIR}/arm-none-eabi-objcopy
OBJDUMP=${TOOLCHAIN_DIR}/arm-none-eabi-objdump

MKIMAGE=u-boot/tools/mkimage

mkdir -p ${BUILD_DIR}
mkdir -p ${INFO_DIR}

${ASM} -o ${BUILD_DIR}/startup.o ${SRC_DIR}/startup.s

${CC} -c -nostdlib -lgcc -o ${BUILD_DIR}/cstart.o ${SRC_DIR}/cstart.c

${LINKER} -T ${SRC_DIR}/linkscript.ld -o ${BUILD_DIR}/main.elf \
        ${BUILD_DIR}/startup.o ${BUILD_DIR}/cstart.o

${OBJCOPY} -O binary ${BUILD_DIR}/main.elf ${BUILD_DIR}/main.bin

# Files for additional information

${OBJDUMP} -D ${BUILD_DIR}/main.elf > ${INFO_DIR}/disassembly

${OBJDUMP} -t ${BUILD_DIR}/main.elf > ${INFO_DIR}/objects 

${OBJDUMP} -h ${BUILD_DIR}/main.elf > ${INFO_DIR}/sections 

# U-boot stuff

${MKIMAGE} -A arm -C none -T kernel -a 0x60000000 -e 0x60000000 \
    -d ${BUILD_DIR}/main.bin ${BUILD_DIR}/bare-arm.uimg

./create-sd.sh ${BUILD_DIR}/sdcard.img ${BUILD_DIR}/bare-arm.uimg

