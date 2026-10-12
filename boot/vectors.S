/* EL2 vector table. Shared by the phone and QEMU entries. */

.section .text.vectors, "ax"
.align 11
.global el2_vectors
el2_vectors:
    b       el2_unhandled           /* Current EL, SP0, sync */
    .align 7
    b       el2_unhandled           /* IRQ */
    .align 7
    b       el2_unhandled           /* FIQ */
    .align 7
    b       el2_unhandled           /* SError */
    .align 7
    b       el2_unhandled           /* Current EL, SPx, sync */
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled           /* Lower EL, AArch64, sync */
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled
    .align 7
    b       el2_unhandled           /* Lower EL, AArch32, sync */
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