/*
 * QEMU virt reset. UART is boot/uart-qemu.S. Vectors are boot/vectors.S.
 * Handoff matches entry.S: hypervisor_main.
 * The QEMU link does not include the Ada object.
 */

.section .text.boot, "ax"
.global _start
.global halt
.type _start, %function

_start:
    mov     x19, x0

    mrs     x9, mpidr_el1
    and     x9, x9, #0xff
    cbnz    x9, secondary_park

    mrs     x0, CurrentEL
    lsr     x0, x0, #2
    cmp     x0, #3
    b.eq    drop_el3
    cmp     x0, #2
    b.eq    at_el2
    b       halt

drop_el3:
    mov     x0, #((1 << 10) | (1 << 8) | (1 << 0))
    msr     scr_el3, x0
    mov     x0, #0x3c9
    msr     spsr_el3, x0
    adr     x0, at_el2
    msr     elr_el3, x0
    isb
    eret

at_el2:
    msr     daifset, #0xf
    mov     x0, #(1 << 31)
    msr     hcr_el2, x0

    mrs     x0, sctlr_el2
    orr     x0, x0, #(1 << 12)
    bic     x0, x0, #(1 << 0)
    bic     x0, x0, #(1 << 1)
    bic     x0, x0, #(1 << 2)
    bic     x0, x0, #(1 << 3)
    bic     x0, x0, #(1 << 19)
    bic     x0, x0, #(1 << 25)
    msr     sctlr_el2, x0
    isb

    ldr     x0, =_stack_top
    mov     sp, x0
    ldr     x0, =el2_vectors
    msr     vbar_el2, x0
    isb

    bl      clear_bss
    ldr     x0, =banner
    bl      uart_puts

    ldr     x0, =dtb_ptr
    str     x19, [x0]

    mov     x0, x19
    bl      hypervisor_main
    b       halt

secondary_park:
    ldr     x1, =secondary_release
wait_release:
    wfe
    ldr     x0, [x1]
    cbz     x0, wait_release
    br      x0

halt:
    wfe
    b       halt

.size _start, . - _start

.type clear_bss, %function
clear_bss:
    ldr     x0, =_bss_start
    ldr     x1, =_bss_end
1:
    cmp     x0, x1
    b.hs    2f
    str     xzr, [x0], #8
    b       1b
2:
    ret
.size clear_bss, . - clear_bss

.section .rodata
banner:
    .asciz "eggos: qemu virt\n"

.section .bss
.align 3
.global dtb_ptr
dtb_ptr:
    .quad 0
.global secondary_release
secondary_release:
    .quad 0