# Toolchain. Prefer aarch64-none-elf-gcc, fall back to clang.
#   make              phone: entry.S + linker.ld
#   make BOARD=qemu   virt:  entry-qemu.S + uart-qemu.S + vectors.S

CROSS_COMPILE ?= aarch64-none-elf-
TARGET_TRIPLE ?= aarch64-unknown-none
BOARD         ?= mt6761

ifeq ($(shell command -v "$(CROSS_COMPILE)gcc" >/dev/null 2>&1 && echo yes || echo no),yes)
CC      := $(CROSS_COMPILE)gcc
LD      := $(CROSS_COMPILE)ld
OBJCOPY := $(CROSS_COMPILE)objcopy
ASMFLAGS := -ffreestanding -mcpu=cortex-a53
else
CC      := clang
LD      := ld.lld
OBJCOPY := llvm-objcopy
ASMFLAGS := --target=$(TARGET_TRIPLE) -ffreestanding -mcpu=cortex-a53
endif

BUILD_DIR := build
OBJ_DIR   := $(BUILD_DIR)/obj
RUST_LIB  := target/$(TARGET_TRIPLE)/release/libhypervisor.a
ELF       := $(BUILD_DIR)/eggos.elf
BIN       := $(BUILD_DIR)/eggos.bin

ifeq ($(BOARD),qemu)
ENTRY         := boot/entry-qemu.S
UART          := boot/uart-qemu.S
LINKER_SCRIPT := boot/linker-qemu.ld
else
ENTRY         := boot/entry.S
UART          :=
LINKER_SCRIPT := boot/linker.ld
endif

.PHONY: all clean asm ada rust elf binary qemu

all: binary

asm:
	@mkdir -p $(OBJ_DIR)
	$(CC) -c $(ENTRY) -o $(OBJ_DIR)/entry.o $(ASMFLAGS)
	$(CC) -c boot/vectors.S -o $(OBJ_DIR)/vectors.o $(ASMFLAGS)
ifneq ($(UART),)
	$(CC) -c $(UART) -o $(OBJ_DIR)/uart.o $(ASMFLAGS)
endif

ada:
	gprbuild -P eggos.gpr

rust:
	cargo build -p hypervisor --target $(TARGET_TRIPLE) --release

elf: asm rust
ifeq ($(BOARD),qemu)
	$(LD) -T $(LINKER_SCRIPT) \
		$(OBJ_DIR)/entry.o \
		$(OBJ_DIR)/uart.o \
		$(OBJ_DIR)/vectors.o \
		$(RUST_LIB) \
		-o $(ELF)
else
	$(LD) -T $(LINKER_SCRIPT) \
		$(OBJ_DIR)/entry.o \
		$(OBJ_DIR)/vectors.o \
		$(RUST_LIB) \
		-o $(ELF)
endif

binary: elf
	$(OBJCOPY) -O binary $(ELF) $(BIN)

qemu:
	$(MAKE) BOARD=qemu binary

clean:
	cargo clean
	gprclean -P eggos.gpr 2>/dev/null || true
	rm -rf $(BUILD_DIR)