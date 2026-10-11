.section .text.vectors, "ax"
.align 11
.global el2_vectors
el2_vectors:
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled

el2_unhandled:
    ldr     x0, =trap_msg
    bl      uart_puts
    b       halt

.section .rodata
trap_msg:
    .asciz "eggos: el2 trap\n"