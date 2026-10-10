use core::fmt::{self, Write};

pub const UART0_BASE: usize = 0x1100_2000;
const UART_LSR_OFFSET: usize = 0x14;
const UART_LSR_THR_EMPTY: u8 = 1 << 5;

pub struct Uart {
    base_address: usize,
}

impl Uart {
    pub fn new(base_address: usize) -> Self {
        Uart { base_address }
    }

    /// Writes a single byte directly to the UART TX register
    pub fn write_byte(&self, byte: u8) {
        let status = (self.base_address + UART_LSR_OFFSET) as *const u8;
        let tx = self.base_address as *mut u8;
        unsafe {
            while core::ptr::read_volatile(status) & UART_LSR_THR_EMPTY == 0 {
                core::hint::spin_loop();
            }
            core::ptr::write_volatile(tx, byte);
        }
    }
}

// Retain standard Rust formatting support for the main hypervisor payload
impl Write for Uart {
    fn write_str(&mut self, s: &str) -> fmt::Result {
        for byte in s.bytes() {
            if byte == b'\n' {
                self.write_byte(b'\r');
            }
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