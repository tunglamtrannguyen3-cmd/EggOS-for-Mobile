with Interfaces;
use type Interfaces.Unsigned_8;

package body Security_Policy
  with SPARK_Mode => On
is

   function Is_Valid_DRAM_Range
     (Base : Memory_Address;
      Size : Region_Size) return Boolean
   is
   begin
      if Base >= DRAM_Base
        and then Memory_Address (Size) <=
          (DRAM_Base + Memory_Address (DRAM_Size)) - Base
      then
         return True;
      else
         return False;
      end if;
   end Is_Valid_DRAM_Range;

   function Validate_Stage2_Access
     (VM_ID  : Interfaces.Unsigned_8;
      Target : Memory_Address;
      Length : Region_Size) return Boolean
   is
   begin
      if VM_ID >= Max_VMs then
         return False;
      end if;
      return Is_Valid_DRAM_Range (Base => Target, Size => Length);
   end Validate_Stage2_Access;

end Security_Policy;