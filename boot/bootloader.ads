with Interfaces;

package Bootloader with SPARK_Mode => On is
   
   -- Export to C-ABI so boot/entry.S can branch to 'ada_bootloader_main'
   procedure Main (DTB_Addr : Interfaces.Unsigned_64)
     with Export        => True,
          Convention    => C,
          External_Name => "ada_bootloader_main";

end Bootloader;