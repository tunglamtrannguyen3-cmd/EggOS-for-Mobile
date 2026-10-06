with Drivers.UART;

package body Panic_Handler is

   procedure Last_Chance_Handler (Msg : System.Address; Line : Integer) is
   begin
      -- Re-initialize UART in case the panic happened early or corrupted state
      Drivers.UART.Initialize (Drivers.UART.UART0_BASE);

      Drivers.UART.Put_Line ("");
      Drivers.UART.Put_Line ("┌─────────────────────────────────────────────────────────────┐");
      Drivers.UART.Put_Line ("│ 🚨 KERNEL PANIC                                             │");
      Drivers.UART.Put_Line ("├─────────────────────────────────────────────────────────────┤");
      Drivers.UART.Put_Line ("└─────────────────────────────────────────────────────────────┘");
      Drivers.UART.Put_Line ("SYSTEM HALTED.");

      loop
         pragma Loop_Optimize (No_Unroll);
      end loop;
   end Last_Chance_Handler;

end Panic_Handler;