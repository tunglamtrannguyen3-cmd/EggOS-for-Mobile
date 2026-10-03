use core::fmt;
use core::ptr::{read_volatile, write_volatile};

// Physical base address for UART0 on MT6761 (Helio A22)
pub const UART0_BASE: usize = 0x1100_2000;

// MediaTek UART Register Offsets
const UART_THR: usize = 0x00; // Transmit Holding Register
const UART_LSR: usize = 0x14; // Line Status Register
const LSR_TX_EMPTY: u32 = 1 << 5; // Transmitter empty bit

pub struct Uart {
    base_address: usize,
}

impl Uart {
    pub const fn new(base_address: usize) -> Self {
        Uart { base_address }
    }

    fn write_reg(&self, offset: usize, val: u32) {
        unsafe { write_volatile((self.base_address + offset) as *mut u32, val) }
    }

    fn read_reg(&self, offset: usize) -> u32 {
        unsafe { read_volatile((self.base_address + offset) as *const u32) }
    }

    /// Write a single character to the serial port
    pub fn putc(&self, c: u8) {
        // Wait until the transmit buffer is empty
        while self.read_reg(UART_LSR) & LSR_TX_EMPTY == 0 {
            core::hint::spin_loop();
        }
        self.write_reg(UART_THR, c as u32);
    }

    /// Write a string to the serial port
    pub fn puts(&self, s: &str) {
        for byte in s.bytes() {
            if byte == b'\n' {
                self.putc(b'\r');
            }
            self.putc(byte);
        }
    }
}

// Implement fmt::Write to unlock the `write!` and `writeln!` macros
impl fmt::Write for Uart {
    fn write_str(&mut self, s: &str) -> fmt::Result {
        self.puts(s);
        Ok(())
    }
}