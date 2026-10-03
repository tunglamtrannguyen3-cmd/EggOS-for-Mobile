#![no_std]
#![no_main]

use core::panic::PanicInfo;

extern "C" {
    /// Global DTB pointer populated by boot/entry.S
    static dtb_ptr: u64;
}

#[no_mangle]
pub extern "C" fn bootloader_main() -> ! {
    // Read the DTB physical address saved by assembly
    let dtb_addr = unsafe { dtb_ptr };

    // Early MT6761 initialization will go here
    // (Parse DTB, setup early UART, handoff to EL2 hypervisor)

    loop {
        // Wait for event / trap if bootloader returns
        core::hint::spin_loop();
    }
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {
        core::hint::spin_loop();
    }
}