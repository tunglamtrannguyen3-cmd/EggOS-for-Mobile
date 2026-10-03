package body Security_Policy with SPARK_Mode => On is

   function Is_Valid_DRAM_Range (
      Base : Memory_Address;
      Size : Region_Size
   ) return Boolean is
   begin
      -- Checks if the requested region falls strictly within the MT6761's 2GB DRAM
      if Base >= DRAM_Base and then 
         (Base + Memory_Address(Size)) <= (DRAM_Base + Memory_Address(DRAM_Size)) 
      then
         return True;
      else
         return False;
      end if;
   end Is_Valid_DRAM_Range;

   function Validate_Stage2_Access (
      VM_ID     : Interfaces.Unsigned_8;
      Target    : Memory_Address;
      Length    : Region_Size
   ) return Boolean is
   begin
      -- Base security check: Ensure the guest isn't trying to map 
      -- memory outside the physical MT6761 DRAM boundaries.
      -- Future iterations will add logic here to map specific regions to specific VM_IDs.
      return Is_Valid_DRAM_Range (Base => Target, Size => Length);
   end Validate_Stage2_Access;

end Security_Policy;