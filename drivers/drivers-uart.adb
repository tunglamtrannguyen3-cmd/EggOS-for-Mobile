with Interfaces;

package body Drivers.UART
  with SPARK_Mode => On,
       Refined_State => (Port => UART_TX)
is

   procedure Initialize (Base : Interfaces.Unsigned_64) is
      pragma Unreferenced (Base);
   begin
      null;
   end Initialize;

   procedure Put_Line (Item : String)
     with Refined_Global => (Output => UART_TX)
   is
   begin
      for I in Item'Range loop
         UART_TX := Interfaces.Unsigned_32 (Character'Pos (Item (I)));
      end loop;

      UART_TX := 13; -- CR
      UART_TX := 10; -- LF
   end Put_Line;

end Drivers.UART;