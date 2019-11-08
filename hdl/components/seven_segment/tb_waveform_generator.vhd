library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all; 
use IEEE.NUMERIC_STD.all;

entity tb_waveform_generator is

end entity tb_waveform_generator;

architecture rtl of tb_waveform_generator is
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

	unit : entity work.waveform_generator_implementation
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

	-- Data generation
	process
		-- Avalong write sequence
		procedure avsWrite(addr:  in std_logic_vector(7 downto 0); data: in std_logic_vector(31 downto 0)) is
		begin
			avs_s0_write 		<= '1';
			avs_s0_address 		<= addr;
			avs_s0_writedata 	<= data;
			wait for 5*CLOCK_50_period;
			avs_s0_write 		<= '0';
			wait for 20*CLOCK_50_period;
		end avsWrite;

	begin
		-- reset routine
		reset <= '1';
		wait for 5*CLOCK_50_period;
		reset <= '0';
		wait for 5*CLOCK_50_period;

		-- sync to clock - improve!
		wait for CLOCK_50_period/2;

		avsWrite(X"00", X"000000ff");
		avsWrite(X"00", X"00000005");
		avsWrite(X"00", X"0000000c");
		avsWrite(X"00", X"0000000b");
		avsWrite(X"00", X"0000000d");
		avsWrite(X"00", X"0000000e");
		avsWrite(X"00", X"0000000f");

		avsWrite(X"00", X"00000003");
		avsWrite(X"00", X"00000004");

		avsWrite(X"00", X"00000001");



		avsWrite(X"01", X"000000ff");
		avsWrite(X"01", X"00000005");
		avsWrite(X"01", X"0000000c");
		avsWrite(X"01", X"0000000b");
		avsWrite(X"01", X"0000000d");
		avsWrite(X"01", X"0000000e");
		avsWrite(X"01", X"0000000f");

		avsWrite(X"01", X"00000003");
		avsWrite(X"01", X"00000004");

		avsWrite(X"01", X"00000001");



		avsWrite(X"02", X"000000ff");
		avsWrite(X"02", X"00000005");
		avsWrite(X"02", X"0000000c");
		avsWrite(X"02", X"0000000b");
		avsWrite(X"02", X"0000000d");
		avsWrite(X"02", X"0000000e");
		avsWrite(X"02", X"0000000f");

		avsWrite(X"02", X"00000003");
		avsWrite(X"02", X"00000004");

		avsWrite(X"02", X"00000001");

		wait;
	end process;
	
end architecture rtl;
