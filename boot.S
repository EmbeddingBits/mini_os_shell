.global _start
.section .text
_start:
    ldr sp, =stack_top        @ Setup stack
    bl uart_init              @ Initialize UART first
    ldr r0, =hello            @ Print debug boot message
    bl uart_print
    bl shell_loop
    b .                       @ Infinite loop

.section .bss
.comm input_buffer, 128
.comm command, 16

.section .data
stack: .skip 4096
stack_top:

.section .rodata
hello: .asciz "Booting...\n"
