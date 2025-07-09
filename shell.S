.extern uart_recv, uart_send, uart_print, uart_println

.section .text
.global shell_loop

shell_loop:
    ldr r0, =welcome
    bl uart_println

loop:
    ldr r0, =prompt
    bl uart_print

    ldr r1, =input_buffer
    bl read_line

    ldr r0, =input_buffer
    bl handle_command

    b loop

read_line:
    push {r1, r2, r3, lr}
    mov r2, #0
1:
    bl uart_recv
    cmp r0, #13     // Enter key
    beq 2f
    cmp r0, #127    // Backspace
    beq handle_backspace
    cmp r2, #126    // Prevent buffer overflow
    bge 1b
    strb r0, [r1, r2]
    add r2, r2, #1
    bl uart_send
    b 1b
    
handle_backspace:
    cmp r2, #0
    beq 1b
    sub r2, r2, #1
    mov r0, #8      // Backspace
    bl uart_send
    mov r0, #32     // Space
    bl uart_send
    mov r0, #8      // Backspace again
    bl uart_send
    b 1b

2:
    mov r0, #'\n'
    bl uart_send
    mov r3, #0
    strb r3, [r1, r2]
    pop {r1, r2, r3, lr}
    bx lr

handle_command:
    push {r1, r2, lr}
    
    // Check for empty command
    ldrb r2, [r0]
    cmp r2, #0
    beq done
    
    ldr r1, =cmd_echo
    bl strcmp
    cmp r0, #0
    beq do_echo

    ldr r0, =input_buffer    // Restore r0
    ldr r1, =cmd_help
    bl strcmp
    cmp r0, #0
    beq do_help

    ldr r0, =input_buffer    // Restore r0
    ldr r1, =cmd_clear
    bl strcmp
    cmp r0, #0
    beq do_clear

    ldr r0, =input_buffer    // Restore r0
    ldr r1, =cmd_exit
    bl strcmp
    cmp r0, #0
    beq do_exit

    ldr r0, =msg_invalid
    bl uart_println
    b done

do_echo:
    ldr r0, =input_buffer
    add r0, r0, #5   // skip "echo "
    bl uart_println
    b done

do_help:
    ldr r0, =msg_help
    bl uart_println
    b done

do_clear:
    mov r2, #20
1:
    ldr r0, =newline
    bl uart_print
    subs r2, r2, #1
    bne 1b
    b done

do_exit:
    ldr r0, =msg_bye
    bl uart_println
    b .

done:
    pop {r1, r2, lr}
    bx lr

strcmp:
    push {r2, r3}
1:
    ldrb r2, [r0], #1
    ldrb r3, [r1], #1
    cmp r2, r3
    bne notequal
    cmp r2, #0
    beq equal
    b 1b
equal:
    mov r0, #0
    pop {r2, r3}
    bx lr
notequal:
    mov r0, #1
    pop {r2, r3}
    bx lr

.section .rodata
prompt: .asciz "> "
welcome: .asciz "Welcome to EduShell - ARM Assembly Shell"
msg_help: .asciz "Commands: echo, help, clear, exit"
msg_bye: .asciz "Goodbye!"
msg_invalid: .asciz "Invalid command"
newline: .asciz "\n"

cmd_echo: .asciz "echo"
cmd_help: .asciz "help"
cmd_clear: .asciz "clear"
cmd_exit: .asciz "exit"
