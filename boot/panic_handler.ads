with Drivers.UART;
with System;

package Panic_Handler
  with SPARK_Mode => On
is

   procedure Last_Chance_Handler (Msg : System.Address; Line : Integer)
     with Export        => True,
          Convention    => C,
          External_Name => "__gnat_last_chance_handler",
          Global        => (Output => Drivers.UART.Port),
          No_Return     => True;

end Panic_Handler;