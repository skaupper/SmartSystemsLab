-- altera vhdl_input_version vhdl_2008
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seven_segment_implementation is
    port (
        avs_s0_address                 : in  std_logic_vector(7 downto 0)  := (others => '0');
        avs_s0_read                    : in  std_logic                     := '0';
        avs_s0_readdata                : out std_logic_vector(31 downto 0);
        avs_s0_write                   : in  std_logic                     := '0';
        avs_s0_writedata               : in  std_logic_vector(31 downto 0) := (others => '0');
        avs_s0_waitrequest             : out std_logic;
        clk                            : in  std_logic                     := '0';
        reset                          : in  std_logic                     := '0';
        seven_segment                  : out std_logic_vector(41 downto 0)
    );
end entity seven_segment_implementation;

architecture rtl of seven_segment_implementation is

    type bcd_array is array (natural range <>) of std_logic_vector(3 downto 0);

    signal bcd                  : bcd_array(5 downto 0);
    signal pwm_reg              : std_logic_vector(7 downto 0);
    signal pwm_output           : std_logic;
    signal seven_segment_buffer : std_logic_vector(41 downto 0);
    signal enable_reg           : std_logic_vector( 5 downto 0);

begin

    GENERATE_BCD_CONVERTERS: for I in 0 to 5 generate
        bcd_converter_inst : entity work.bcd_to_seven port map (
            bcd             => bcd(i),
            seven_segment   => seven_segment_buffer(6+7*I downto 7*I)
        );
    end generate;

    pwm_controller_inst : entity work.pwm_controller generic map (
        dataWidth => 8
    ) port map (
        clk     => clk,
        reset   => reset,
        value   => pwm_reg,
        output  => pwm_output
    );

    process(clk, reset)
    begin
        if reset = '1' then
            bcd             <= (others => (others => '0'));
            enable_reg      <= (others => '0');
            pwm_reg         <= (others => '0');

            avs_s0_readdata <= (others => '0');
        elsif rising_edge(clk) then
            if avs_s0_write = '1' then
                -- What should we do?
                case avs_s0_address(3 downto 0) is
                    -- Write to the display
                    when X"0" =>
                        for i in 0 to 5 loop
                            bcd(i) <= avs_s0_writedata(3+4*i downto 4*i);
                        end loop;

                    -- Change the PWM value (0 to 255)
                    when X"1" =>
                        pwm_reg <= avs_s0_writedata(7 downto 0);

                    -- The enable_reg register
                    when X"2" =>
                        enable_reg <= avs_s0_writedata(5 downto 0);

                    when others => null;
                end case;
            end if;

            if avs_s0_read = '1' then
                avs_s0_readdata <= (others => '0');

                case avs_s0_address(3 downto 0) is
                    -- Write to the display
                    when x"0" =>
                        for i in 0 to 5 loop
                            avs_s0_readdata(3+4*i downto 4*i) <= bcd(i);
                        end loop;

                    -- Change the PWM value (0 to 255)
                    when x"1" =>
                        avs_s0_readdata(7 downto 0) <= pwm_reg;

                    -- The enable_reg register
                    when x"2" =>
                        avs_s0_readdata(5 downto 0) <= enable_reg;

                    when others => null;
                end case;
            end if;
        end if;
    end process;

    process(enable_reg, pwm_output, seven_segment_buffer)
    begin
        seven_segment <= (others => '1');
        for i in 0 to 5 loop
            if pwm_output = '1' and enable_reg(i) = '1' then
                seven_segment(6+7*i downto 7*i) <= seven_segment_buffer(6+7*i downto 7*i);
            end if;
        end loop;
    end process;


    avs_s0_waitrequest <= '0';

end architecture rtl;
