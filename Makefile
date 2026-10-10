# Toolchain configuration for bare-metal AArch64
CROSS_COMPILE ?= aarch64-none-elf-
CC            := $(CROSS_COMPILE)gcc
LD            := $(CROSS_COMPILE)ld
OBJCOPY       := $(CROSS_COMPILE)objcopy

TARGET_TRIPLE := aarch64-unknown-none
BUILD_DIR     := build
OBJ_DIR       := $(BUILD_DIR)/obj

LINKER_SCRIPT := boot/linker.ld
RUST_LIB      := target/$(TARGET_TRIPLE)/release/libhypervisor.a
ELF           := $(BUILD_DIR)/eggos.elf
BIN           := $(BUILD_DIR)/eggos.bin

.PHONY: all clean asm ada rust elf binary

all: binary

# 1. Assemble early boot entry (uses GCC preprocessor for boot/entry.S)
asm:
	@mkdir -p $(OBJ_DIR)
	$(CC) -c boot/entry.S -o $(OBJ_DIR)/entry.o -ffreestanding -mcpu=cortex-a53

# Compile Ada/SPARK components for host-side checks. These objects are not
# included in the firmware until an AArch64 GNAT toolchain is configured.
ada:
	gprbuild -P eggos.gpr

# Build Rust crates (bundles drivers + hypervisor into libhypervisor.a)
rust:
	cargo build -p hypervisor --target $(TARGET_TRIPLE) --release

# Link the AArch64 entry point and Rust static library into the firmware ELF.
elf: asm rust
	$(LD) -T $(LINKER_SCRIPT) \
		$(OBJ_DIR)/entry.o \
		$(RUST_LIB) \
		-o $(ELF)

# 5. Extract raw binary image for MT6761 preloader
binary: elf
	$(OBJCOPY) -O binary $(ELF) $(BIN)

clean:
	cargo clean
	gprclean -P eggos.gpr 2>/dev/null || true
	rm -rf $(BUILD_DIR)