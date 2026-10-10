#![no_std]
#![no_main]

use core::fmt::Write;
use drivers::uart::{Uart, UART0_BASE};

// Re-export the FFI bridge for the Ada bootloader
pub use drivers::uart::eggos_uart_put_char;

#[no_mangle]
pub extern "C" fn hypervisor_main(dtb_addr: u64) -> ! {
    let mut serial = Uart::new(UART0_BASE);
    
    // If this appears, the firmware reached Rust from the assembly entry point.
    let _ = writeln!(serial, "[Rust] Hypervisor Core initialized at EL2.");
    let _ = writeln!(serial, "[Rust] DTB address: {:#x}", dtb_addr);
    let _ = writeln!(serial, "[Rust] Awaiting guest OS handoff...");

    // Halt the CPU for now until we write the VM scheduler
    loop {
        unsafe { core::arch::asm!("wfe") };
    }
}

// 2. Build a Real Panic Path
#[panic_handler]
fn panic(info: &core::panic::PanicInfo) -> ! {
    let mut serial = Uart::new(UART0_BASE);
    
    let _ = writeln!(serial, "\n=================================");
    let _ = writeln!(serial, "KERNEL PANIC IN RUST HYPERVISOR");
    let _ = writeln!(serial, "=================================");
    
    if let Some(location) = info.location() {
        let _ = writeln!(serial, "Location: {}:{}", location.file(), location.line());
    }
    
    let _ = writeln!(serial, "System halted.");
    
    loop {
        unsafe { core::arch::asm!("wfi") }; // Wait For Interrupt
    }
}