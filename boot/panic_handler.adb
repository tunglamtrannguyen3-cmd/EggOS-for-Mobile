with Drivers.UART;
with System;

package body Panic_Handler
  with SPARK_Mode => On
is

   procedure Last_Chance_Handler (Msg : System.Address; Line : Integer) is
      pragma Unreferenced (Msg);
      pragma Unreferenced (Line);
   begin
      Drivers.UART.Initialize (Drivers.UART.UART0_BASE);
      Drivers.UART.Put_Line ("KERNEL PANIC");
      Drivers.UART.Put_Line ("SYSTEM HALTED.");
      loop
         null;
      end loop;
   end Last_Chance_Handler;

end Panic_Handler;