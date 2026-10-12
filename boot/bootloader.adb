with Interfaces;

package body Bootloader
  with SPARK_Mode => On
is

   procedure Hypervisor_Main
     with Import        => True,
          Convention    => C,
          External_Name => "hypervisor_main",
          Global        => null,
          No_Return;

   procedure Main (DTB_Addr : Interfaces.Unsigned_64) is
      pragma Unreferenced (DTB_Addr);
   begin
      Hypervisor_Main;
   end Main;

end Bootloader;