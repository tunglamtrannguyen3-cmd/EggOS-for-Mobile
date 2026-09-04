# 🥚 EggOS Architecture

## Target Platform: ARM64 Mobile

EggOS is designed for ARM64 mobile devices (phones, tablets).

### Core Components

#### 1. **Bootloader** (`/bootloader`)
- ARM64 UEFI bootloader entry point
- Device tree parsing
- Memory initialization
- Hands off to kernel

**Sources:**
- Limine bootloader (adapted for ARM64)
- UEFI specs
- ARM64 boot protocol

#### 2. **Kernel** (`/kernel`)
- ARM64 core scheduling, memory management, IPC
- Modular architecture inspired by NASA cFS concepts
- Minimal, focused implementation

**Sources:**
- Linux kernel (selected components)
- NASA cFS architecture patterns
- ARM64 architecture reference manual

#### 3. **Runtime** (`/runtime`)
- System services and drivers
- User-facing APIs
- App lifecycle management

#### 4. **Crypto & Security** (`/crypto`)
- TLS/cryptography (OpenSSL primitives)
- Secure boot verification
- User data encryption

### Directory Structure

```
EggOS-for-Mobile/
├── bootloader/          # ARM64 boot code
├── kernel/              # Core OS kernel
├── runtime/             # System runtime & services
├── crypto/              # Cryptography & security
├── drivers/             # Device drivers (ARM64 targets)
├── docs/                # Architecture & design docs
├── vendor/              # Upstream source attributions
└── CREDITS.md           # Full licensing & attribution
```

### Build System

- **CMake** for cross-platform ARM64 builds
- **GCC/LLVM ARM64 toolchain**
- Minimal, no external dependencies beyond what's needed

---

**Status:** Pre-alpha. Architecture phase.
