with Interfaces;
with System;

package Drivers.UART
  with SPARK_Mode => On,
       Abstract_State =>
         (Port with External => (Async_Readers, Async_Writers, Effective_Writes))
is
   UART0_BASE : constant Interfaces.Unsigned_64 := 16#1100_2000#;

   procedure Initialize (Base : Interfaces.Unsigned_64)
     with Global => null;

   procedure Put_Line (Item : String)
     with Global => (Output => Port);

private
   pragma Warnings (GNATprove, Off, "volatile properties",
                    Reason => "UART MMIO register; no other object overlays it");
   pragma Warnings (GNATprove, Off, "non-volatile objects",
                    Reason => "UART MMIO register; no other object overlays it");
   UART_TX : Interfaces.Unsigned_32
     with Import,
          Volatile,
          Atomic,
          Async_Readers,
          Async_Writers,
          Effective_Writes,
          Part_Of => Port,
          Address => System'To_Address (16#1100_2000#);
   pragma Warnings (GNATprove, On, "volatile properties");
   pragma Warnings (GNATprove, On, "non-volatile objects");
end Drivers.UART;