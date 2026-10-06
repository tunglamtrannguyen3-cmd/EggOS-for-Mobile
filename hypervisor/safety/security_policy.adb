with Interfaces;
use type Interfaces.Unsigned_8;

package body Security_Policy is

   function Is_Valid_DRAM_Range (
      Base : Memory_Address;
      Size : Region_Size
   ) return Boolean is
   begin
      -- Check the requested region falls within the MT6761's 2GB DRAM.
      -- Subtraction and short-circuiting prevent modular wrap-around.
      if Base >= DRAM_Base
        and then Memory_Address (Size) <=
          (DRAM_Base + Memory_Address (DRAM_Size)) - Base
      then
         return True;
      else
         return False;
      end if;
   end Is_Valid_DRAM_Range;

   function Validate_Stage2_Access (
      VM_ID  : Interfaces.Unsigned_8;
      Target : Memory_Address;
      Length : Region_Size
   ) return Boolean is
   begin
      -- Validate the VM ID.
      if VM_ID >= Max_VMs then
         return False;
      end if;

      -- Validate physical memory bounds.
      return Is_Valid_DRAM_Range (Base => Target, Size => Length);
   end Validate_Stage2_Access;

end Security_Policy;
