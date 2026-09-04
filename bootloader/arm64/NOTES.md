# ARM64 Bootloader Notes

## Overview

EggOS ARM64 bootloader is designed for modern mobile devices with UEFI firmware.

## Boot Sequence

1. **UEFI Firmware** → Loads and executes EggOS.efi
2. **EggOS Bootloader** 
   - Parse UEFI boot parameters
   - Set up minimal runtime (exit boot services)
   - Parse device tree or ACPI tables
   - Initialize ARM64 exception vectors
   - Load kernel image
3. **Transfer to Kernel** → Hand over control to kernel with boot info

## ARM64 Specifics

- **Entry point:** `_start` in `entry.s`
- **Exception levels:** EL2 (hypervisor) → EL1 (kernel)
- **Memory:** Flat address space with MMU disabled initially
- **Interrupts:** Disabled until kernel takes over
- **Registers:** X0-X30, SP, LR

## References

- ARM ARM v8.x-A (ARM Architecture Reference Manual)
- UEFI Specification 2.10+
- Device Tree Specification v0.3+
- Linux kernel ARM64 boot protocol (for compatibility reference)

## Status

- [ ] Basic entry point and exception vectors
- [ ] UEFI bootloader stub
- [ ] Device tree parsing
- [ ] Memory initialization
- [ ] Kernel handoff

---

**Source attribution:** Concepts adapted from Limine bootloader and Linux ARM64 boot code.
