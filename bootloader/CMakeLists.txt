add_executable(bootloader.elf
    arm64/entry.s
    arm64/boot.c
)

target_include_directories(bootloader.elf PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# ARM64-specific linker flags
target_link_options(bootloader.elf PRIVATE
    -T${CMAKE_CURRENT_SOURCE_DIR}/arm64/linker.ld
    -nostdlib
    -static
)

# Generate binary image
add_custom_command(TARGET bootloader.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary bootloader.elf bootloader.bin
    COMMENT "Generating bootloader binary"
)
