with Interfaces;
use type Interfaces.Unsigned_8;

package Security_Policy with SPARK_Mode => On is


   type Memory_Address is new Interfaces.Unsigned_64;
   type Region_Size is new Interfaces.Unsigned_64;

   -- MT6761 Physical DRAM Layout Constraints
   DRAM_Base : constant Memory_Address := 16#4000_0000#;
   DRAM_Size : constant Region_Size    := 16#8000_0000#; -- 2GB MAX for MT6761
   
   -- Hypervisor Limits
   Max_VMs : constant Interfaces.Unsigned_8 := 4; -- Support up to 4 VMs (IDs 0-3)

   function Is_Valid_DRAM_Range (
      Base : Memory_Address;
      Size : Region_Size
   ) return Boolean
     with Post => (if Is_Valid_DRAM_Range'Result then
                     Base >= DRAM_Base and then
                     Memory_Address(Size) <= (DRAM_Base + Memory_Address(DRAM_Size)) - Base);

   function Validate_Stage2_Access (
      VM_ID     : Interfaces.Unsigned_8;
      Target    : Memory_Address;
      Length    : Region_Size
   ) return Boolean
     with Export        => True,
          Convention    => C, 
          External_Name => "ada_validate_stage2_access",
          Post          => (if Validate_Stage2_Access'Result then VM_ID < Max_VMs);

end Security_Policy;