.section .text
.global uart_putc
.global uart_puts

.equ UART0,    0x11002000
.equ UART_THR, 0x00
.equ UART_LSR, 0x14

uart_putc:
    ldr     x1, =UART0
1:
    ldr     w2, [x1, #UART_LSR]
    tbz     w2, #5, 1b
    str     w0, [x1, #UART_THR]
    ret

uart_puts:
    stp     x29, x30, [sp, #-32]!
    stp     x19, x20, [sp, #16]
    mov     x20, x0
2:
    ldrb    w0, [x20], #1
    cbz     w0, 3f
    cmp     w0, #'\n'
    b.ne    4f
    mov     w0, #'\r'
    bl      uart_putc
    mov     w0, #'\n'
4:
    bl      uart_putc
    b       2b
3:
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #32
    ret