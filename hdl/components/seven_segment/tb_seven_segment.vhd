library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all; 
use IEEE.NUMERIC_STD.all;

entity tb_seven_segment_implementation is

end entity tb_seven_segment_implementation;

architecture rtl of tb_seven_segment_implementation is
	signal dataWidth			: integer := 16;
	constant CLOCK_50_period	: time := 20 ns;

	signal CLOCK_50				: std_logic := '0';
	signal reset				: std_logic := '0';

	signal avs_s0_address     	: std_logic_vector(7 downto 0)  := (others => '0');
	signal avs_s0_read        	: std_logic                     := '0';            
	signal avs_s0_readdata    	: std_logic_vector(31 downto 0);                   
	signal avs_s0_write       	: std_logic                     := '0';            
	signal avs_s0_writedata   	: std_logic_vector(31 downto 0) := (others => '0');
	signal avs_s0_waitrequest 	: std_logic;                                        
	signal seven_segment      	: std_logic_vector(41 downto 0);  

begin

	unit : entity work.seven_segment_implementation
	port map(
		avs_s0_address     => avs_s0_address,
		avs_s0_read        => avs_s0_read,
		avs_s0_readdata    => avs_s0_readdata,
		avs_s0_write       => avs_s0_write,
		avs_s0_writedata   => avs_s0_writedata,
		avs_s0_waitrequest => avs_s0_waitrequest,
		clk                => CLOCK_50,
		reset              => reset
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

		avs_s0_address 		<= X"00";
		avs_s0_writedata 	<= X"00123456";
		avs_s0_write 		<= '1';
		wait for 5*CLOCK_50_period;

		wait;
	end process;
	
end architecture rtl;
