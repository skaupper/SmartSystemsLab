-- hdc1000.vhd

-- This file was auto-generated as a prototype implementation of a module
-- created in component editor.  It ties off all outputs to ground and
-- ignores all inputs.  It needs to be edited to make it do something
-- useful.
-- 
-- This file will not be automatically regenerated.  You should check it in
-- to your version control system if you want to keep it.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity hdc1000 is
   generic (
      gclock_frequency : natural := 100E6;
   )
   port (
      avs_s0_address   : in  std_logic_vector(7 downto 0)  := (others => '0'); -- avs_s0.address
      avs_s0_read      : in  std_logic                     := '0';             --       .read
      avs_s0_readdata  : out std_logic_vector(31 downto 0);                    --       .readdata
      avs_s0_write     : in  std_logic                     := '0';             --       .write
      avs_s0_writedata : in  std_logic_vector(31 downto 0) := (others => '0'); --       .writedata
      iClk             : in  std_logic                     := '0';             --  clock.clk
      inRst            : in  std_logic                     := '0'              --  reset.reset
   );
end entity hdc1000;

architecture rtl of hdc1000 is
   signal ms_tick : std_ulogic;
begin

   count_proc : process( iClk, inRst )
      constant ccounter_length : natural = LogDualis(gclock_frequency);
      variable cnt : unsigned(ccounter_length-1 downto 0) := (others => '0');
   begin
      if inRst = '0' then
         cnt := (others => '0')
      elsif (rising_edge(iClk)) then
         cnt :=  
      end if;
   end process ; -- count_proc



   avs_s0_readdata <= "00000000000000000000000000000000";

end architecture rtl; -- of new_component
