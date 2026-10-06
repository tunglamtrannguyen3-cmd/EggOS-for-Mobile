with System;

package Panic_Handler is

   -- This procedure overrides the default Ada runtime panic behavior.
   -- The compiler automatically looks for the "__gnat_last_chance_handler" symbol 
   -- when an exception occurs in a No_Run_Time (bare-metal) environment.
   procedure Last_Chance_Handler (Msg : System.Address; Line : Integer)
     with Export        => True, 
          Convention    => C, 
          External_Name => "__gnat_last_chance_handler",
          No_Return     => True;

end Panic_Handler;