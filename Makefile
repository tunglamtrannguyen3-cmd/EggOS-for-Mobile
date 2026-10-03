# Toolchain configuration for bare-metal AArch64
CROSS_COMPILE ?= aarch64-none-elf-
AS            := $(CROSS_COMPILE)as
OBJCOPY       := $(CROSS_COMPILE)objcopy

TARGET_TRIPLE := aarch64-unknown-none
BUILD_DIR     := build

.PHONY: all clean asm ada rust binary

all: binary

# 1. Assemble early boot entry (Grok's Assembly stub)
asm:
	@mkdir -p $(BUILD_DIR)
	$(AS) -c boot/entry.S -o $(BUILD_DIR)/entry.o

# 2. Compile Ada/SPARK security verification code
ada:
	gprbuild -P eggos.gpr

# 3. Build Rust crates
rust:
	cargo build --target $(TARGET_TRIPLE) --release

# 4. Extract raw binary image for MT6761 preloader/brom
binary: asm ada rust
	@mkdir -p $(BUILD_DIR)
	$(OBJCOPY) -O binary target/$(TARGET_TRIPLE)/release/boot $(BUILD_DIR)/eggos.bin

clean:
	cargo clean
	gprclean -P eggos.gpr 2>/dev/null || true
	rm -rf $(BUILD_DIR)