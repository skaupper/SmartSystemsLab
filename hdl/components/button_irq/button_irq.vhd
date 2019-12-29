library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- 0 -> lower word of timestamp
-- 1 -> higher word of timestamp
-- 14 -> ISR (button state)

entity button_irq is
   generic (
      gClkFrequency    : natural := 50E6;
      gI2cFrequency    : natural := 400E3);
   port (
      clk_i               : in  std_logic;
      rst_i              : in  std_logic;

      button_i           : in   std_ulogic_vector(1 downto 0);
      interrupt_o        : out  std_logic;

      avs_s0_address     : in  std_logic_vector( 1 downto 0);
      avs_s0_read        : in  std_logic;
      avs_s0_readdata    : out std_logic_vector(31 downto 0);
      avs_s0_write       : in  std_logic;
      avs_s0_writedata   : in  std_logic_vector(31 downto 0)
   );
end entity button_irq;

architecture rtl of button_irq is
    -- Avalon Slave Adresses
  constant cAddrData : std_logic_vector(1 downto 0) := "00";
  constant cAddrTsLo : std_logic_vector(1 downto 0) := "01";
  constant cAddrTsUp : std_logic_vector(1 downto 0) := "10";

  constant cMsFrequency : natural := 1E3;

  constant cTimestampWidth : natural := 64;
  subtype timestamp_t is unsigned (cTimestampWidth-1 downto 0);


  type aRegSet is record
    readdata  : std_ulogic_vector(avs_s0_readdata'range);
  end record;

  constant cRegSetClear : aRegSet := (
    readdata  => (others => '0'));

  signal timestamp : timestamp_t;
  signal msTick    : std_ulogic;

  signal readdata  : std_ulogic_vector(avs_s0_readdata'range);
  signal reg, nxR : aRegSet;

begin -- architecture rtl

  strobe : entity work.StrobeGen
  generic map (
    gClkFrequency    => gClkFrequency,
    gStrobeFrequency => cMsFrequency)
  port map (
    clk_i             => clk_i,
    inResetAsync     => rst_i,
    oStrobe          => msTick);

   comb : process(reg, avs_s0_read, avs_s0_address, avm_m0_readdata, avm_m0_waitrequest)
   begin
      -- Defaults
      nxR           <= reg;
      nxR.readdata  <= (others => '0');

      -- Read access bus logic
      if avs_s0_read = '1' then
         case( avs_s0_address ) is
            when cAddrData =>
               nxR.readdata(15 downto 0) <= reg.reg.light;
               nxR.lock     <= '1';
            when cAddrTsLo =>
               nxR.readdata <= std_ulogic_vector(timestamp(31 downto 0));
               nxR.lock     <= '1';
            when cAddrTsUp =>
               nxR.readdata <= std_ulogic_vector(timestamp(63 downto 32));
               nxR.lock     <= '0';
            when others =>
               null;
         end case ;
      end if;
   end process comb;

   regs : process(clk_i, rst_i)
   begin
    if (rising_edge(clk_i)) then
      if rst_i = '0' then
        timestamp <= 0;
        readdata <= (others => '0');

        reg <= cRegSetClear;
        reg <= nxR;
      else
        if msTick = '1' then
          timestamp <= timestamp + 1;
        end if;
      end if;
    end if;
   end process regs;

   avs_s0_readdata  <= std_logic_vector(readdata);

end architecture rtl; -- of button_irq
