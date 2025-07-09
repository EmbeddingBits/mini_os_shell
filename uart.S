/* UART for QEMU (versatilepb board) */
.global uart_init, uart_send, uart_recv, uart_print, uart_println, newline

.section .text

uart_init:
    ldr r0, =0x101f1000       // UART0 base for QEMU
    mov r1, #0
    str r1, [r0, #0x0C]       // Disable UART (stub)
    mov r1, #1
    str r1, [r0, #0x30]       // Enable UART (stub)
    mov r1, #0x3
    str r1, [r0, #0x2C]       // Enable Tx/Rx (stub)
    bx lr

uart_send:
    push {r1, r2}
    ldr r1, =0x101f1000
1:
    ldr r2, [r1, #0x18]       // Flag register
    tst r2, #0x20             // TXFF (Transmit FIFO full)
    bne 1b
    strb r0, [r1]
    pop {r1, r2}
    bx lr

uart_recv:
    push {r1, r2}
    ldr r1, =0x101f1000
1:
    ldr r2, [r1, #0x18]       // Flag register
    tst r2, #0x10             // RXFE (Receive FIFO empty)
    bne 1b                    // Fixed: was beq, should be bne
    ldrb r0, [r1]
    pop {r1, r2}
    bx lr

uart_print:
    push {r1, lr}             // Save lr as well
1:
    ldrb r1, [r0], #1
    cmp r1, #0
    beq 2f
    push {r0}                 // Save r0 before uart_send
    mov r0, r1
    bl uart_send
    pop {r0}                  // Restore r0
    b 1b
2:
    pop {r1, lr}
    bx lr

uart_println:
    push {lr}
    bl uart_print
    ldr r0, =newline
    bl uart_print
    pop {lr}
    bx lr

.section .rodata
newline: .asciz "\n"
