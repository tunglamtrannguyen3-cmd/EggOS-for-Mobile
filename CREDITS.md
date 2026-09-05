# 🥚 EggOS Credits & Upstream Sources

EggOS builds upon the work of amazing open-source projects. All code is reused in compliance with original licenses.

---


## Operating System Concepts: NASA Core Flight System (cFS)

**Source:** https://github.com/nasa/cFE  
**License:** Apache 2.0  
**Usage:** Modular OS architecture, error handling patterns, component isolation

NASA's Core Flight System demonstrates enterprise-grade OS design with modularity, clear separation of concerns, and rigorous error handling.

**How we use it:**
- Module/component architecture patterns
- Inter-component communication (IPC) design
- Error handling and logging strategies
- Configuration management approaches

---

## Cryptography: OpenSSL

**Source:** https://github.com/openssl/openssl  
**License:** Apache 2.0  
**Usage:** TLS/SSL implementation, cryptographic primitives

OpenSSL provides industry-standard cryptography for secure communications and data protection.

**How we use it:**
- AES, SHA, HMAC implementations
- TLS/SSL protocol stack
- Certificate handling and verification
- Random number generation (where not using hardware RNG)

---

## Linux Kernel (Selected Components)

**Source:** https://github.com/torvalds/linux  
**License:** GPL 2.0  
**Usage:** ARM64 architecture support, driver infrastructure, syscall conventions

The Linux kernel is the reference implementation for ARM64 support and provides battle-tested patterns for hardware abstraction.

**How we use it:**
- ARM64 exception handling and interrupt management
- Memory management unit (MMU) initialization
- Device driver frameworks (concepts, not direct copies)
- Syscall conventions for ARM64

**Note:** EggOS is **not** a Linux fork. We borrow architectural concepts and reference implementations where appropriate, following GPL compliance.

---

## License Compliance

All reused code retains its original copyright notice and license file. When EggOS incorporates code from these projects:

1. **Source attribution** is included in relevant source files
2. **License files** are preserved in `/vendor/<project>/LICENSE`
3. **Original authors** are credited in code comments
4. **Substantial modifications** are documented

### EggOS Licensing

- **Original EggOS code:** MIT License
- **Reused upstream code:** Retains original license (Apache 2.0, GPL 2.0, BSD 2-Clause)

Comply with all applicable licenses when modifying or distributing EggOS.

---

## Contributing

If you contribute code to EggOS:
- Reference any upstream sources you're using
- Keep copyright notices intact
- Follow the license of any code you're adapting

---

**Last updated:** 2026-09-04  
🥚 **EggOS — built on the shoulders of giants, credited properly.**
