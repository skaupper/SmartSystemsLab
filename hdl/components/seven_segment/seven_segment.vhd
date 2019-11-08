-- altera vhdl_input_version vhdl_2008
-- seven_segment.vhd

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

entity seven_segment is
    port (
        avs_s0_address     : in  std_logic_vector(7 downto 0)  := (others => '0'); --          s0.address
        avs_s0_read        : in  std_logic                     := '0';             --            .read
        avs_s0_readdata    : out std_logic_vector(31 downto 0);                    --            .readdata
        avs_s0_write       : in  std_logic                     := '0';             --            .write
        avs_s0_writedata   : in  std_logic_vector(31 downto 0) := (others => '0'); --            .writedata
        avs_s0_waitrequest : out std_logic;                                        --            .waitrequest
        clk                : in  std_logic                     := '0';             --       clock.clk
        reset              : in  std_logic                     := '0';             --       reset.reset
        seven_segment      : out std_logic_vector(41 downto 0)                     -- conduit_end.export
    );
end entity seven_segment;

architecture rtl of seven_segment is
begin

    seven_segment_implementation_inst : entity work.seven_segment_implementation
    port map (
        avs_s0_address     => avs_s0_address,
        avs_s0_read        => avs_s0_read,
        avs_s0_readdata    => avs_s0_readdata,
        avs_s0_write       => avs_s0_write,
        avs_s0_writedata   => avs_s0_writedata,
        avs_s0_waitrequest => avs_s0_waitrequest,
        clk                => clk,
        reset              => reset,
        seven_segment      => seven_segment
    );

end architecture rtl; -- of seven_segment
