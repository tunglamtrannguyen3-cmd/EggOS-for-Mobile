/*
 * eggos boot entry. AArch64 reset vector for MT6761.
 *
 * Chainload payload. Clocks and DRAM are already up.
 * Link address: 0x40080000 (boot/linker.ld).
 *
 * x0 on entry is the DTB. Core 0 publishes it and calls the Rust
 * hypervisor entry point. Cores 1-3 wait on secondary_release.
 */

.section .text.boot, "ax"
.global _start
.type _start, %function

.equ UART0,    0x11002000
.equ UART_THR, 0x00
.equ UART_LSR, 0x14

_start:
    mov     x19, x0                 /* DTB, before anything clobbers x0 */

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
    mov     x0, #((1 << 10) | (1 << 8) | (1 << 0))  /* SCR_EL3: RW | HCE | NS */
    msr     scr_el3, x0
    mov     x0, #0x3c9              /* DAIF masked, EL2h */
    msr     spsr_el3, x0
    adr     x0, at_el2
    msr     elr_el3, x0
    isb
    eret

at_el2:
    msr     daifset, #0xf

    mov     x0, #(1 << 31)          /* HCR_EL2.RW: EL1 is AArch64 */
    msr     hcr_el2, x0

    mrs     x0, sctlr_el2
    orr     x0, x0, #(1 << 12)      /* I */
    bic     x0, x0, #(1 << 0)       /* M */
    bic     x0, x0, #(1 << 1)       /* A */
    bic     x0, x0, #(1 << 2)       /* C */
    bic     x0, x0, #(1 << 3)       /* SA */
    bic     x0, x0, #(1 << 19)      /* WXN */
    bic     x0, x0, #(1 << 25)      /* EE */
    msr     sctlr_el2, x0
    isb

    ldr     x0, =_stack_top
    mov     sp, x0

    adr     x0, el2_vectors
    msr     vbar_el2, x0
    isb

    bl      clear_bss

    adr     x0, banner
    bl      uart_puts

    ldr     x0, =dtb_ptr
    str     x19, [x0]

    mov     x0, x19                 /* pass the DTB to the Rust entry point */
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
bss_loop:
    cmp     x0, x1
    b.hs    bss_done
    str     xzr, [x0], #8
    b       bss_loop
bss_done:
    ret
.size clear_bss, . - clear_bss

.type uart_putc, %function
uart_putc:
    ldr     x1, =UART0
uart_wait:
    ldr     w2, [x1, #UART_LSR]
    tbz     w2, #5, uart_wait
    str     w0, [x1, #UART_THR]
    ret
.size uart_putc, . - uart_putc

.type uart_puts, %function
uart_puts:
    stp     x29, x30, [sp, #-32]!
    stp     x19, x20, [sp, #16]
    mov     x20, x0
puts_loop:
    ldrb    w0, [x20], #1
    cbz     w0, puts_done
    cmp     w0, #'\n'
    b.ne    puts_raw
    mov     w0, #'\r'
    bl      uart_putc
    mov     w0, #'\n'
puts_raw:
    bl      uart_putc
    b       puts_loop
puts_done:
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #32
    ret
.size uart_puts, . - uart_puts

.section .rodata
banner:
    .asciz "eggos: ada entry\n"
trap_msg:
    .asciz "eggos: el2 trap\n"

.section .bss
.align 3
.global dtb_ptr
dtb_ptr:
    .quad 0

.global secondary_release
secondary_release:
    .quad 0

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
    adr     x0, trap_msg
    bl      uart_puts
    b       halt
