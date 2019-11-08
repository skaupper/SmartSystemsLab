-- altera vhdl_input_version vhdl_2008
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcd_to_seven is
    port (
        bcd             : in    std_logic_vector(3 downto 0);
        seven_segment   : out   std_logic_vector(6 downto 0)
    );
end bcd_to_seven;

--      0
--    ------
--    |    |
--   5| 6  |1
--    ------
--    |    |
--   4|    |2
--    ------
--      3
-- 1 = off / 0 = on

architecture rtl of bcd_to_seven is

begin

    process(bcd)
    begin
        case bcd is
            when "0000" => seven_segment <= "1000000";  -- '0'
            when "0001" => seven_segment <= "1111001";  -- '1'
            when "0010" => seven_segment <= "0100100";  -- '2'
            when "0011" => seven_segment <= "0110000";  -- '3'
            when "0100" => seven_segment <= "0011001";  -- '4'
            when "0101" => seven_segment <= "0010010";  -- '5'
            when "0110" => seven_segment <= "0000010";  -- '6'
            when "0111" => seven_segment <= "1111000";  -- '7'
            when "1000" => seven_segment <= "0000000";  -- '8'
            when "1001" => seven_segment <= "0010000";  -- '9'
            when "1010" => seven_segment <= "0001000";  -- 'A'
            when "1011" => seven_segment <= "0000011";  -- 'b'
            when "1100" => seven_segment <= "1000110";  -- 'C'
            when "1101" => seven_segment <= "0100001";  -- 'd'
            when "1110" => seven_segment <= "0000110";  -- 'E'
            when "1111" => seven_segment <= "0001110";  -- 'F'
            when others =>
        end case;
    end process;

end rtl;
