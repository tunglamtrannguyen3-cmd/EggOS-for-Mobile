with Interfaces;

package Bootloader with SPARK_Mode => On is

   procedure Main (DTB_Addr : Interfaces.Unsigned_64)
     with Export        => True,
          Convention    => C,
          External_Name => "bootloader_main",
          No_Return;

end Bootloader;