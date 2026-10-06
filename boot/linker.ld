ENTRY(_start)

/* MT6761 DRAM starts at 0x4000_0000. 
   We load at an offset so we don't overwrite early firmware. */
BASE_ADDRESS = 0x40080000;

SECTIONS
{
    . = BASE_ADDRESS;

    /* 1. BOOT ENTRY POINT */
    /* This must be the very first thing in the binary. */
    /* The KEEP directive ensures the linker doesn't optimize it away. */
    .text.boot : {
        KEEP(*(.text.boot))
    }

    /* 2. EXECUTABLE CODE (Ada & Rust) */
    .text : {
        *(.text .text.*)
    }

    /* 3. READ-ONLY DATA (Strings, constants, etc.) */
    .rodata : {
        *(.rodata .rodata.*)
    }

    /* 4. INITIALIZED DATA */
    .data : {
        *(.data .data.*)
    }

    /* 5. UNINITIALIZED DATA (BSS) */
    /* We mark the start and end so your entry.S can zero this memory out before calling Ada */
    .bss (NOLOAD) : ALIGN(8) {
        __bss_start = .;
        *(.bss .bss.*)
        *(COMMON)
        __bss_end = .;
    }

    /* 6. DISCARD SECTION */
    /* Strip out standard unwinding/exception info to keep the binary small */
    /DISCARD/ : {
        *(.eh_frame)
        *(.eh_frame_hdr)
    }
}