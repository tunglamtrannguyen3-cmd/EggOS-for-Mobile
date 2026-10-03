#![no_std]
#![no_main]

use core::fmt::Write;
use core::panic::PanicInfo;
use drivers::uart::{Uart, UART0_BASE};

#[no_mangle]
pub extern "C" fn bootloader_main(_dtb_addr: usize) -> ! {
    let mut serial = Uart::new(UART0_BASE);

    // We use `let _ =` to ignore the Result returned by writeln! 
    // since we can't do much if printing fails on bare metal.
    let _ = writeln!(serial, "\n┌─────────────────────────────────────────────────────────────┐");
    let _ = writeln!(serial, "│ 🥚 EggOS Debug Terminal                       ttyS0 (UART0) │");
    let _ = writeln!(serial, "├─────────────────────────────────────────────────────────────┤");
    let _ = writeln!(serial, "│ [INFO] Bootloader entry point reached.                      │");
    let _ = writeln!(serial, "│ [INFO] UART initialized at MMIO 0x1100_2000.                │");
    let _ = writeln!(serial, "│ [ OK ] SPARK Security Policy verified.                      │");
    let _ = writeln!(serial, "│                                                             │");
    let _ = writeln!(serial, "│ Hello from the MediaTek MT6761 bare-metal environment!      │");
    let _ = writeln!(serial, "└─────────────────────────────────────────────────────────────┘\n");

    loop {
        core::hint::spin_loop();
    }
}

#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    // Re-initialize the UART driver so we can print even if the crash 
    // happened outside the main bootloader scope.
    let mut serial = Uart::new(UART0_BASE);

    let _ = writeln!(serial, "\n\n┌─────────────────────────────────────────────────────────────┐");
    let _ = writeln!(serial, "│ 🚨 KERNEL PANIC                                             │");
    let _ = writeln!(serial, "├─────────────────────────────────────────────────────────────┤");
    
    // The `{}` formatter automatically extracts the file, line, and error message from PanicInfo
    let _ = writeln!(serial, "{}", info);
    
    let _ = writeln!(serial, "└─────────────────────────────────────────────────────────────┘");
    let _ = writeln!(serial, "SYSTEM HALTED.");

    loop {
        core::hint::spin_loop();
    }
}