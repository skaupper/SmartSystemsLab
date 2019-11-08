library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all; 
use IEEE.NUMERIC_STD.all;

entity tb_pwm_controller is

end entity tb_pwm_controller;

architecture rtl of tb_pwm_controller is
	signal dataWidth			: integer := 8;
	constant CLOCK_50_period	: time := 20 ns;

	signal CLOCK_50				: std_logic := '0';
	signal reset				: std_logic := '0';
	signal value 				: std_logic_vector(dataWidth-1 downto 0) := X"10";

begin

	unit : entity work.pwm_controller
	port map(
        clk 		=> CLOCK_50,
        reset       => reset,
    
        value       => value
	);

	-- Clock generation
	process
	begin
		CLOCK_50 <= '0';
		wait for CLOCK_50_period/2;
		CLOCK_50 <= '1';
		wait for CLOCK_50_period/2;
	end process;

	process

	begin
		-- reset routine
		reset <= '1';
		wait for 5*CLOCK_50_period;
		reset <= '0';
		wait for 5*CLOCK_50_period;

		-- sync to clock - improve!
		wait for CLOCK_50_period/2;

		value <= X"70";
		wait for 1000*CLOCK_50_period;
		value <= X"0A";
		wait for 1000*CLOCK_50_period;
		value <= X"FB";
		wait for 1000*CLOCK_50_period;

		wait;
	end process;
	
end architecture rtl;
