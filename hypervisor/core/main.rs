#![no_std]
#![no_main]

// Re-export the FFI bridge so it gets bundled into libhypervisor.a 
// and the Ada bootloader can find it.
pub use drivers::uart::eggos_uart_put_char;

#[no_mangle]
pub extern "C" fn hypervisor_main() -> ! {
    loop {
        unsafe { core::arch::asm!("wfe") };
    }
}

#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    loop {}
}