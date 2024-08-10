cmake_minimum_required (VERSION 3.20)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_CROSSCOMPILING TRUE)

set(UBOOT_PATH "${CMAKE_SOURCE_DIR}/u-boot")
set(MKIMAGE "${UBOOT_PATH}/tools/mkimage")

project (bare-metal-arm 
         LANGUAGES C ASM)

set(COMPILER_BASE_PATH "/opt/gcc-arm-none-eabi-9.3.1/bin")
set(CMAKE_C_COMPILER "${COMPILER_BASE_PATH}/arm-none-eabi-gcc")
set(CMAKE_ASM_COMPILER "${COMPILER_BASE_PATH}/arm-none-eabi-as")
set(CMAKE_OBJCOPY "${COMPILER_BASE_PATH}/arm-none-eabi-objcopy")

set(LINKSCRIPT "${CMAKE_SOURCE_DIR}/src/linkscript.ld")
set(ASMFILES "${CMAKE_SOURCE_DIR}/src/startup.s")
set(SRCLIST "${CMAKE_SOURCE_DIR}/src/cstart.c" 
    "${CMAKE_SOURCE_DIR}/src/uart_pl011.c")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -nostartfiles -g -Wall")
set(CMAKE_EXE_LINKER_FLAGS "-T ${LINKSCRIPT} -lgcc -lm")

add_custom_target(u-boot 
            COMMAND make vexpress_ca9x4_config ARCH=arm CROSS_COMPILE=/opt/gcc-arm-none-eabi-9.3.1/bin/arm-none-eabi- 
            COMMAND make all ARCH=arm CROSS_COMPILE=/opt/gcc-arm-none-eabi-9.3.1/bin/arm-none-eabi- 
            WORKING_DIRECTORY ${UBOOT_PATH})

add_executable(bare-metal ${SRCLIST} ${ASMFILES})
set_target_properties(bare-metal PROPERTIES OUTPUT_NAME "bare-metal.elf")
add_dependencies(bare-metal u-boot)

add_custom_command(TARGET bare-metal POST_BUILD COMMAND ${CMAKE_OBJCOPY}
    -O binary bare-metal.elf bare-metal.bin COMMENT "Converting ELF to binary")

add_custom_command(TARGET bare-metal POST_BUILD COMMAND ${MKIMAGE}
    -A arm -C none -T kernel -a 0x60000000 -e 0x60000000 -d bare-metal.bin bare-arm.uimg
    COMMENT "Building U-Boot image")

add_custom_command(TARGET bare-metal POST_BUILD COMMAND bash ${CMAKE_SOURCE_DIR}/scripts/create-sd.sh 
    sdcard.img bare-arm.uimg
    COMMENT "Creating SD card image")

add_custom_target(run)
add_custom_command(TARGET run POST_BUILD COMMAND 
                 qemu-system-arm -M vexpress-a9 -m 512M -no-reboot -nographic 
                 -monitor telnet:127.0.0.1:1234,server,nowait -kernel ${UBOOT_PATH}/u-boot -sd ${CMAKE_BINARY_DIR}/sdcard.img -serial mon:stdio
                 COMMENT "Running QEMU...")

string(CONCAT GDBSCRIPT "target remote localhost:2159\n"
                        "file bare-metal.elf")
file(WRITE ${CMAKE_BINARY_DIR}/gdbscript ${GDBSCRIPT})

add_custom_target(drun)
add_custom_command(TARGET drun PRE_BUILD COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan
                    "To connect the debugger, run arm-none-eabi-gdb -x gdbscript")
add_custom_command(TARGET drun PRE_BUILD COMMAND ${CMAKE_COMMAND} -E cmake_echo_color --cyan
                    "To start execution, type continue in gdb")

add_custom_command(TARGET drun POST_BUILD COMMAND
                 qemu-system-arm -S -M vexpress-a9 -m 512M -no-reboot -nographic -gdb tcp::2159
                 -monitor telnet:127.0.0.1:1234,server,nowait -kernel ${UBOOT_PATH}/u-boot -sd sdcard.img -serial mon:stdio
                 COMMENT "Running QEMU with debug server...")

