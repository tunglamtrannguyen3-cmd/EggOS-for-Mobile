ENTRY(_start)

SECTIONS
{
    . = 0x40000000;

    .text : ALIGN(16)
    {
        KEEP(*(.text._start))
        *(.text*)
    }

    .rodata : ALIGN(16)
    {
        *(.rodata*)
    }

    .data : ALIGN(16)
    {
        *(.data*)
    }

    .bss : ALIGN(16)
    {
        __bss_start = .;
        *(.bss*)
        *(COMMON)
        __bss_end = .;
    }

    . = ALIGN(16);
    __stack_top = . + 0x10000;
}