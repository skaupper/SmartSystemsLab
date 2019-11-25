-- hdc1000-ea.vhd

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

entity hdc1000 is
   generic (
      gClkFrequency    : natural := 100E6);
   port ( 
      iClk             : in  std_logic                     := '0';             -- clock.clk 
      inRst            : in  std_logic                     := '0'              -- reset.reset 
      avs_s0_address   : in  std_logic_vector( 1 downto 0) := (others => '0'); -- avs_s0.address
      avs_s0_read      : in  std_logic                     := '0';             --       .read
      avs_s0_readdata  : out std_logic_vector(31 downto 0);                    --       .readdata
      avs_s0_write     : in  std_logic                     := '0';             --       .write
      avs_s0_writedata : in  std_logic_vector(31 downto 0) := (others => '0'); --       .writedata
      avm_m0_address   : out std_logic_vector( 2 downto 0) := (others => '0'); -- avs_m0.address
      avm_m0_read      : out std_logic                     := '0';             --       .read
      avm_m0_readdata  : in  std_logic_vector(31 downto 0);                    --       .readdata
      avm_m0_write     : out std_logic                     := '0';             --       .write
      avm_m0_writedata : out std_logic_vector(31 downto 0) := (others => '0'); --       .writedata
   );
end entity hdc1000;

architecture rtl of hdc1000 is
   constant cTimestampWidth : natural := 64;
   subtype aTimestamp is unsigned (cTimestampWidth-1 downto 0);
   
   constant cSensorValueWidth : natural := 16;
   subtype aSensorValue is std_ulogic_vector (cSensorValueWidth-1 downto 0);

   -- I2C Avalon Adresses
   constant cTrfrCmdAddr        : std_logic_vector(1 downto 0) := "000";
   constant cRxDataAddr         : std_logic_vector(1 downto 0) := "001";
   constant cCtrlAddr           : std_logic_vector(1 downto 0) := "010";
   constant cISERAddr           : std_logic_vector(1 downto 0) := "011";
   constant cISRAddr            : std_logic_vector(1 downto 0) := "100";
   constant cStatAddr           : std_logic_vector(1 downto 0) := "101";
   constant cTrfrCmdFifoLvlAddr : std_logic_vector(1 downto 0) := "110";
   constant cRxDataFifoLvlAddr  : std_logic_vector(1 downto 0) := "111";

   -- Avalon Adresses
   constant cAddrData : std_logic_vector(1 downto 0) := "00";
   constant cAddrTsLo : std_logic_vector(1 downto 0) := "01";
   constant cAddrTsUp : std_logic_vector(1 downto 0) := "10";

   type aValueSet is record
      timestamp   : aTimestamp;
      temperature : aSensorValue;
      humidity    : aSensorValue;
   end record;

   constant cValueSetClear : aValueSet := (
      timestamp   => (others => '0'),
      temperature => (others => '0'),
      humidity    => (others => '0'));

   type aRegSet is record
      lock      : std_ulogic;
      readdata  : std_ulogic_vector(31 downto 0);
      reg       : aValueSet;
      shadowReg : aValueSet;
   end record;

   constant cRegSetClear : aRegSet := (
      lock      => '0',
      readdata  => (others => '0'),
      reg       => cValueSetClear,
      shadowReg => cValueSetClear);

   signal msTick   : std_ulogic;
   signal reg, nxR : aRegSet;
begin

   prescaler : process( iClk, inRst )
      constant cCountMax : natural := gClkFrequency / 1000 - 1;
      subtype  aCount   is natural range 0 to cCountMax;
      variable cnt : aCount := 0;
   begin
      if inRst = '0' then
         cnt := 0;
         msTick <= '0';
      elsif (rising_edge(iClk)) then
         msTick <= '0';
         if cnt = cCountMax then
            cnt    :=  0;
            msTick <= '1';
         else
            cnt := cnt + 1;
         end if;
      end if;
   end process ; -- prescaler

   fsm : process( reg, avs_s0_read, msTick, avs_s0_address )
   begin
      nxR <= reg;
      nxR.readdata <= (others => '0');

      -- Timestamp logic
      if msTick = '1' then
         nxR.shadowReg.timestamp <= reg.shadowReg.timestamp + 1;
      end if;

      -- Load shadow reg to actual reg
      if reg.lock = '0' then
         nxR.reg <= reg.shadowReg;
      end if;

      -- Pseudo values
      nxR.shadowReg.humidity    <= std_ulogic_vector(nxR.shadowReg.timestamp(15 downto 0));
      nxR.shadowReg.temperature <= std_ulogic_vector(nxR.shadowReg.timestamp(15 downto 0));

      -- Bus logic
      if avs_s0_read = '1' then
         case( avs_s0_address ) is
            when cAddrData =>
               nxR.readdata <= reg.reg.humidity & reg.reg.temperature;
               nxR.lock     <= '1';

            when cAddrTsLo =>
               nxR.readdata <= std_ulogic_vector(reg.reg.timestamp(31 downto 0));
               nxR.lock     <= '1';

            when cAddrTsUp =>
               nxR.readdata <= std_ulogic_vector(reg.reg.timestamp(63 downto 32));
               nxR.lock     <= '0';

            when others =>
               null;
         end case ;
      end if;
   end process; -- fsm

   regProc : process( iClk, inRst )
   begin
      if inRst = '0' then
         reg <= cRegSetClear;
      elsif (rising_edge(iClk)) then
         reg <= nxR;
      end if;
   end process ; -- regProc

   avs_s0_readdata <= std_logic_vector(reg.readdata);

end architecture rtl; -- of new_component
