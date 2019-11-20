-- TbdHdc1000-ea.vhd

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

-- 0 -> upper 16 bit: humidity, lower 16 bit: temperature
-- 1 -> lower word of timestamp
-- 2 -> upper word of timestamp

entity tbHdc1000 is
end entity tbHdc1000;

architecture bhv of tbHdc1000 is
   signal avs_s0_address   : std_logic_vector( 1 downto 0) := (others => '0'); -- avs_s0.address
   signal avs_s0_read      : std_logic                     := '0';             --       .read
   signal avs_s0_readdata  : std_logic_vector(31 downto 0);                    --       .readdata
   signal avs_s0_write     : std_logic                     := '0';             --       .write
   signal avs_s0_writedata : std_logic_vector(31 downto 0) := (others => '0'); --       .writedata
   signal clk             : std_logic                      := '0';             --  clock.clk
   signal nRst            : std_logic                      := '0';             --  reset.reset
begin

   nRst <= '1' after 20 ns;
   clk  <= not clk after 5 ns;

   Dut : entity work.hdc1000
   generic map (
      gClkFrequency => 10000)
   port map (
      avs_s0_address   => avs_s0_address,
      avs_s0_read      => avs_s0_read,
      avs_s0_readdata  => avs_s0_readdata,
      avs_s0_write     => avs_s0_write,
      avs_s0_writedata => avs_s0_writedata,
      iClk             => clk,
      inRst            => nRst);

   test_proc : process
   begin
      wait for 1000 ns;
      wait until clk = '0';

      avs_s0_address  <= "00";
      avs_s0_read     <= '1';

      wait until clk  <= '1';
      wait until clk  <= '0';

      avs_s0_address  <= "01";
      avs_s0_read     <= '1';

      wait until clk  <= '1';
      wait until clk  <= '0';

      avs_s0_address  <= "10";
      avs_s0_read     <= '1';

      wait until clk  <= '1';
      wait until clk  <= '0';

      avs_s0_address  <= "00";
      avs_s0_read     <= '0';

      wait;
   end process; -- test_proc

end architecture bhv; -- of new_component
