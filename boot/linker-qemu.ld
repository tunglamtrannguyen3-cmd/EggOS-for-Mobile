ENTRY(_start)

MEMORY
{
    RAM (rwx) : ORIGIN = 0x40000000, LENGTH = 512M
}

SECTIONS
{
    . = 0x40000000;
    
    .text : {
        KEEP(*(.text.boot))
        *(.text .text.*)
    } > RAM

    .rodata : {
        *(.rodata .rodata.*)
    } > RAM

    .data : {
        *(.data .data.*)
    } > RAM

    .bss (NOLOAD) : ALIGN(8) {
        __bss_start = .;
        *(.bss .bss.*)
        *(COMMON)
        *(.bss.stack)
        __bss_end = .;
    } > RAM

    /DISCARD/ : {
        *(.comment)
        *(.note*)
    }
}