/*
 * eggos full boot entry. AArch64 reset / chainload vector for MT6761.
 *
 * Assumes the preloader already brought up clocks and DRAM.
 * Link address is 0x40080000 (boot/linker.ld).
 *
 * Entry contract with bootloader.rs:
 *   x0 on entry     DTB physical address (Linux / LK boot protocol)
 *   dtb_ptr         published after BSS clear, read by Rust
 *   bootloader_main noreturn Rust entry
 *
 * Core 0 owns init. Cores 1-3 spin on secondary_release until core 0
 * writes a jump address there.
 */

.section .text.boot, "ax"
.global _start
.type _start, %function

.equ UART0,     0x11002000
.equ UART_THR,  0x00
.equ UART_LSR,  0x14

_start:
    /* Stash DTB before any instruction clobbers x0. */
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
    /* Non-secure AArch64 EL2. HCE so EL2 can take its own IRQs later. */
    mov     x0, #((1 << 10) | (1 << 8) | (1 << 0))  /* RW | HCE | NS */
    msr     scr_el3, x0
    mov     x0, #0x3c9              /* DAIF masked, M[4]=0, EL2h */
    msr     spsr_el3, x0
    adr     x0, at_el2
    msr     elr_el3, x0
    isb
    eret

at_el2:
    msr     daifset, #0xf

    /* EL1 is AArch64. Stage-2 (VM) stays off until the host installs it. */
    mov     x0, #(1 << 31)          /* HCR_EL2.RW */
    msr     hcr_el2, x0

    /* I-cache on. MMU, D-cache, alignment check, endian swap off. */
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

    /* BSS clear wiped dtb_ptr. Publish the stashed DTB, then enter Rust. */
    ldr     x0, =dtb_ptr
    str     x19, [x0]
    bl      bootloader_main
    b       halt

/* Cores 1-3. core 0 writes an entry PC to secondary_release. */
secondary_park:
    ldr     x1, =secondary_release
1:
    wfe
    ldr     x0, [x1]
    cbz     x0, 1b
    br      x0

halt:
    wfe
    b       halt

.size _start, . - _start

.type clear_bss, %function
clear_bss:
    ldr     x0, =_bss_start
    ldr     x1, =_bss_end
2:
    cmp     x0, x1
    b.hs    3f
    str     xzr, [x0], #8
    b       2b
3:
    ret
.size clear_bss, . - clear_bss

/* MT6577-compatible UART0 at 0x11002000. Polling, 8-bit writes. */

.type uart_putc, %function
uart_putc:
    ldr     x1, =UART0
4:
    ldr     w2, [x1, #UART_LSR]
    tbz     w2, #5, 4b              /* LSR.THRE */
    str     w0, [x1, #UART_THR]
    ret
.size uart_putc, . - uart_putc

.type uart_puts, %function
uart_puts:
    stp     x29, x30, [sp, #-32]!
    stp     x19, x20, [sp, #16]
    mov     x29, sp
    mov     x20, x0
5:
    ldrb    w0, [x20], #1
    cbz     w0, 6f
    cmp     w0, #'\n'
    b.ne    7f
    mov     w0, #'\r'
    bl      uart_putc
    mov     w0, #'\n'
7:
    bl      uart_putc
    b       5b
6:
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #32
    ret
.size uart_puts, . - uart_puts

.section .rodata
banner:
    .asciz "eggos: el2 entry\n"
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

/*
 * EL2 vector table. 16 slots, each 0x80 bytes, table 2 KiB aligned.
 * VBAR_EL2 points here. Stubs print and halt; the host can replace them.
 */
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
