ENTRY(_start)

/* virt RAM starts at 0x40000000. Names match entry-qemu.S. */
BASE_ADDRESS = 0x40000000;

SECTIONS
{
    . = BASE_ADDRESS;

    .text.boot : {
        KEEP(*(.text.boot))
    }

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

    .bss (NOLOAD) : ALIGN(8) {
        _bss_start = .;
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(16);
        _bss_end = .;
    }

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