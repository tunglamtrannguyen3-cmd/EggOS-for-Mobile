use core::fmt::{self, Write};

pub const UART0_BASE: usize = 0x1100_2000;

pub struct Uart {
    base_address: usize,
}

impl Uart {
    pub fn new(base_address: usize) -> Self {
        Uart { base_address }
    }

    /// Writes a single byte directly to the UART TX register
    pub fn write_byte(&self, byte: u8) {
        let ptr = self.base_address as *mut u8;
        unsafe {
            // Volatile write ensures the compiler doesn't optimize away the hardware interaction
            core::ptr::write_volatile(ptr, byte);
        }
    }
}

// Retain standard Rust formatting support for the main hypervisor payload
impl Write for Uart {
    fn write_str(&mut self, s: &str) -> fmt::Result {
        for byte in s.bytes() {
            self.write_byte(byte);
        }
        Ok(())
    }
}

// ==========================================
// FFI BRIDGE FOR ADA BOOTLOADER
// ==========================================

#[no_mangle]
pub extern "C" fn eggos_uart_put_char(c: u8) {
    let uart = Uart::new(UART0_BASE);
    
    // Automatically translate newline (LF) to carriage return + newline (CRLF) 
    // for proper serial terminal formatting
    if c == b'\n' {
        uart.write_byte(b'\r');
    }
    
    uart.write_byte(c);
}