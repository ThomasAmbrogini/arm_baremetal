.equ MODE_FIQ, 0x11
.equ MODE_IRQ, 0x12
.equ MODE_SVC, 0x13

.section .vector_table, "x"
.global _Reset
_Reset:
    b Reset_Handler
    b . /* 0x4 Undefined Instruction */
    b . /* 0x8 Software Interrupt */
    b . /* 0xC Prefetch Abort */
    b . /* 0x10 Data Abort */
    b . /* 0x14 Reserved */
    b . /* 0x18 IRQ */
    b . /* 0x1C FIQ */

.section .text
Reset_Handler:
    msr cpsr_c, #MODE_FIQ
    ldr r1, =_fiq_stack_start
    ldr sp, =_fiq_stack_end
    movw r0, #0xFEFE
    movt r0, #0xFEFE

fiq_loop:
    cmp r1, sp
    strlt r0, [r1], #4
    blt fiq_loop

CopyDataToRAM:
    ldr r0, =_text_end
    ldr r1, =_data_start
    ldr r2, =_data_end

DataLoop:
    cmp r1, r2
    ldrlt r3, [r0], #4
    strlt r3, [r1], #4
    blt DataLoop

BssInit:
    mov r0, #0
    ldr r1, =_bss_start
    ldr r2, =_bss_end

BssLoop:
    cmp r1, r2
    strlt r0, [r1], #4
    blt BssLoop
        
JumpFakeMain:
    bl fake_main
    b AbortException 

AbortException:
    swi 0xFF
