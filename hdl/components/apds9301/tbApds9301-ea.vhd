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

entity tbApds9301 is
end entity tbApds9301;

architecture bhv of tbApds9301 is
   signal avs_s0_address   : std_logic_vector( 1 downto 0) := (others => '0'); -- avs_s0.address
   signal avs_s0_read      : std_logic                     := '0';             --       .read
   signal avs_s0_readdata  : std_logic_vector(31 downto 0);                    --       .readdata
   signal avs_s0_write     : std_logic                     := '0';             --       .write
   signal avs_s0_writedata : std_logic_vector(31 downto 0) := (others => '0'); --       .writedata
   signal avm_m0_address   : std_logic_vector( 5 downto 0) := (others => '0'); -- avs_s0.address
   signal avm_m0_read      : std_logic                     := '0';             --       .read
   signal avm_m0_readdata  : std_logic_vector(31 downto 0);                    --       .readdata
   signal avm_m0_write     : std_logic                     := '0';             --       .write
   signal avm_m0_waitrequest : std_logic                     := '0';             --       .write
   signal avm_m0_writedata : std_logic_vector(31 downto 0) := (others => '0'); --       .writedata
   signal clk             : std_logic                      := '0';             --  clock.clk
   signal nRst            : std_logic                      := '0';             --  reset.reset
   signal nApdsInterrupt  : std_logic                      := '0';             --  reset.reset
begin

   nRst <= '1' after 20 ns;
   clk  <= not clk after 5 ns;

   Dut : entity work.apds9301
   generic map (
      gClkFrequency => 5000)
   port map (
      avs_s0_address   => avs_s0_address,
      avs_s0_read      => avs_s0_read,
      avs_s0_readdata  => avs_s0_readdata,
      avs_s0_write     => avs_s0_write,
      avs_s0_writedata => avs_s0_writedata,
      avm_m0_address   => avm_m0_address,
      avm_m0_read      => avm_m0_read,
      avm_m0_readdata  => avm_m0_readdata,
      avm_m0_write     => avm_m0_write,
      avm_m0_waitrequest => avm_m0_waitrequest,
      avm_m0_writedata => avm_m0_writedata,
      iClk             => clk,
      inRst            => nRst,
      inApdsInterrupt  => nApdsInterrupt);

   test_proc : process
   begin
      wait for 700 ns;
      wait until clk = '0';

      reg_loop : for i in 0 to 2**avs_s0_address'length-1 loop
         avs_s0_address  <= std_logic_vector(to_unsigned(i, avs_s0_address'length));
         avs_s0_read     <= '1';

         wait until clk  <= '1';
         wait until clk  <= '0';
      end loop ; -- reg_loop

      avs_s0_address  <= "00";
      avs_s0_read     <= '0';

      wait;
   end process; -- test_proc

end architecture bhv; -- of new_component
