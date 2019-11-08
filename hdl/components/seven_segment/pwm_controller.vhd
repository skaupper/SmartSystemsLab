-- altera vhdl_input_version vhdl_2008
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Note: Duty cycle range is 0% to 99%

entity pwm_controller is
    generic (
        datawidth       : integer := 8
    );
    port (
        clk             : in     std_logic;
        reset           : in     std_logic;

        value           : in     std_logic_vector(dataWidth-1 downto 0);
        output          : buffer std_logic
    );
end pwm_controller;

architecture rtl of pwm_controller is
    signal counter      : std_logic_vector(dataWidth-1 downto 0);
begin

    process(clk, reset, counter, value)
    begin

        if reset = '1' then

            output <= '0';
            counter <= (others => '0');

        elsif rising_edge(clk) then

            counter <= counter + 1;
            if counter = value then
                output <= '0';
            end if;
            if counter = (counter'range => '1') then
                output <= '1';
            end if;

        end if;

    end process;

end rtl;
