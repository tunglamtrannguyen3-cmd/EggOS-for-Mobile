ENTRY(_start)

/* MT6761 DRAM starts at 0x40000000.
   Load at an offset so this image does not overwrite early firmware. */
BASE_ADDRESS = 0x40080000;

SECTIONS
{
    . = BASE_ADDRESS;

    /* Reset code. Must be first. */
    .text.boot : {
        KEEP(*(.text.boot))
    }

    /* EL2 vector table. entry.S aligns it to 2 KiB. Keep it out of .text. */
    .text.vectors : ALIGN(2048) {
        KEEP(*(.text.vectors))
    }

    .text : {
        *(.text .text.*)
    }

    .rodata : {
        *(.rodata .rodata.*)
    }

    .data : {
        *(.data .data.*)
    }

    /* Names match clear_bss in entry.S: _bss_start / _bss_end. */
    .bss (NOLOAD) : ALIGN(8) {
        _bss_start = .;
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(16);
        _bss_end = .;
    }

    /* entry.S does: ldr x0, =_stack_top; mov sp, x0 */
    . = ALIGN(16);
    _stack_bottom = .;
    . += 64K;
    _stack_top = .;

    /DISCARD/ : {
        *(.eh_frame)
        *(.eh_frame_hdr)
        *(.comment)
        *(.note.*)
    }
}