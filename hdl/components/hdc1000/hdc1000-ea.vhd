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
use work.Global.all;

-- 0 -> upper 16 bit: humidity, lower 16 bit: temperature
-- 1 -> lower word of timestamp
-- 2 -> upper word of timestamp

entity hdc1000 is
   generic (
      gClkFrequency    : natural := 100E6);
   port ( 
      iClk               : in  std_logic                     := '0';             -- clock.clk 
      inRst              : in  std_logic                     := '0';             -- reset.reset 
      avs_s0_address     : in  std_logic_vector( 1 downto 0) := (others => '0'); -- avs_s0.address
      avs_s0_read        : in  std_logic                     := '0';             --       .read
      avs_s0_readdata    : out std_logic_vector(31 downto 0);                    --       .readdata
      avs_s0_write       : in  std_logic                     := '0';             --       .write
      avs_s0_writedata   : in  std_logic_vector(31 downto 0) := (others => '0'); --       .writedata
      avm_m0_address     : out std_logic_vector( 5 downto 0) := (others => '0'); -- avs_m0.address
      avm_m0_read        : out std_logic                     := '0';             --       .read
      avm_m0_readdata    : in  std_logic_vector(31 downto 0);                    --       .readdata
      avm_m0_write       : out std_logic                     := '0';             --       .write
      avm_m0_writedata   : out std_logic_vector(31 downto 0) := (others => '0'); --       .writedata
      avm_m0_waitrequest : in  std_logic; --       .writedata
      iHdcRdy            : in  std_logic
   );
end entity hdc1000;

architecture rtl of hdc1000 is
   constant cTimestampWidth : natural := 64;
   subtype aTimestamp is unsigned (cTimestampWidth-1 downto 0);

   constant cMsFrequency : natural := 1E3;
   
   constant cSensorValueWidth : natural := 16;
   subtype aSensorValue is std_ulogic_vector (cSensorValueWidth-1 downto 0);

   -- I2C Avalon Adresses
   constant cTrfrCmdAddr        : std_ulogic_vector(3 downto 0) := X"0";
   constant cRxDataAddr         : std_ulogic_vector(3 downto 0) := X"1";
   constant cCtrlAddr           : std_ulogic_vector(3 downto 0) := X"2";
   constant cISERAddr           : std_ulogic_vector(3 downto 0) := X"3";
   constant cISRAddr            : std_ulogic_vector(3 downto 0) := X"4";
   constant cStatAddr           : std_ulogic_vector(3 downto 0) := X"5";
   constant cTrfrCmdFifoLvlAddr : std_ulogic_vector(3 downto 0) := X"6";
   constant cRxDataFifoLvlAddr  : std_ulogic_vector(3 downto 0) := X"7";

   -- I2C Addresses
   constant cHdcReadAddr  : std_ulogic_vector(7 downto 0) := X"81";
   constant cHdcWriteAddr : std_ulogic_vector(7 downto 0) := X"80";

   -- HDC Reg Addresses
   constant cHdcTempAddr  : std_ulogic_vector(7 downto 0) := X"00";
   constant cHdcHumAddr   : std_ulogic_vector(7 downto 0) := X"01";
   constant cHdcCfgAddr   : std_ulogic_vector(7 downto 0) := X"02";

   -- Avalon Adresses
   constant cAddrData : std_logic_vector(1 downto 0) := "00";
   constant cAddrTsLo : std_logic_vector(1 downto 0) := "01";
   constant cAddrTsUp : std_logic_vector(1 downto 0) := "10";

   constant cMaxCount : unsigned(4 downto 0) := to_unsigned(20, 5);

   type aAvmRegSet is record
      addr  : std_ulogic_vector( 3 downto 0);
      wData : std_ulogic_vector(31 downto 0);
      write : std_ulogic;
      read  : std_ulogic;
   end record;

   constant cAvmRegSetClear : aAvmRegSet := (
      addr  => (others => '0'),
      wData => (others => '0'),
      write => '0',
      read  => '0'
   );

   type aValueSet is record
      timestamp   : aTimestamp;
      temperature : aSensorValue;
      humidity    : aSensorValue;
   end record;

   constant cValueSetClear : aValueSet := (
      timestamp   => (others => '0'),
      temperature => (others => '0'),
      humidity    => (others => '0'));

   type aHdcState is (
      Init, InitI2c, InitHdc1, InitHdc2, InitHdc3, InitHdc4,
      Idle,
      StartMeasureTemp1, StartMeasureTemp2,
      WaitTemp1, WaitTemp2,
      TempWrCmd1, TempWrCmd2, TempRdCmd1, TempRdCmd2, TempRdCmd3,
      StartMeasureHum1, StartMeasureHum2,
      WaitHum1, WaitHum2,
      HumWrCmd1, HumWrCmd2, HumRdCmd1, HumRdCmd2, HumRdCmd3,
      WaitRead, TmpRead1, TmpRead2, HumRead1, HumRead2
   );

   type aRegSet is record
      lock      : std_ulogic;
      readdata  : std_ulogic_vector(31 downto 0);
      reg       : aValueSet;
      counter   : unsigned(4 downto 0);
      read      : std_ulogic;
      shadowReg : aValueSet;
      avm       : aAvmRegSet;
      timestamp : aTimestamp;
      valid     : std_ulogic;
      hdcState  : aHdcState;
   end record;

   constant cRegSetClear : aRegSet := (
      lock      => '0',
      readdata  => (others => '0'),
      reg       => cValueSetClear,
      counter   => (others => '0'),
      read      => cInactivated,
      shadowReg => cValueSetClear,
      avm       => cAvmRegSetClear,
      timestamp => (others => '0'),
      valid     => '0',
      hdcState  => Idle);

   signal msTick   : std_ulogic;
   signal reg, nxR : aRegSet;
   signal hdcRdy, hdcRdySync : std_ulogic;
begin

   strobe : entity work.StrobeGen
   generic map (
      gClkFrequency    => gClkFrequency,
      gStrobeFrequency => cMsFrequency)
   port map (
      iClk             => iClk,
      inResetAsync     => inRst,
      oStrobe          => msTick);

   fsm : process( reg, avs_s0_read, msTick, avs_s0_address )
   begin
      nxR <= reg;
      nxR.readdata <= (others => '0');
      nxR.read <= cInactivated;
      nxR.avm.addr  <= (others => '0');
      nxR.avm.wData <= (others => '0');
      nxR.avm.read  <= '0';
      nxR.avm.write <= '0';

      -- Timestamp logic
      if msTick = '1' then
         nxR.timestamp <= reg.timestamp + 1;
      end if;

      -- Load shadow reg to actual reg
      if reg.lock = '0' AND reg.valid = '1' then
         nxR.reg <= reg.shadowReg;
      end if;

      if msTick = cActivated then
         nxR.counter <= reg.counter + 1;

         if reg.counter = (cMaxCount-1) then
            nxR.read <= cActivated;
            nxR.counter <= (others => '0');
         end if;
      end if;

      case reg.hdcState is
         when Init =>
            nxR.hdcState <= InitI2c;
         when InitI2c =>
            nxR.avm.addr  <= cCtrlAddr;
            nxR.avm.wData(1 downto 0) <= '1' & '1';
            nxR.avm.write <= cActivated;
            nxR.hdcState <= InitHdc1;
         when InitHdc1 =>
            nxR.avm.addr  <= cTrfrCmdAddr;
            nxR.avm.wData(9 downto 0) <= '1' & '0' & cHdcWriteAddr;
            nxR.avm.write <= cActivated;
            nxR.hdcState <= InitHdc2;
         when InitHdc2 =>
            nxR.avm.addr  <= cTrfrCmdAddr;
            nxR.avm.wData(9 downto 0) <= '0' & '0' & cHdcCfgAddr;
            nxR.avm.write <= cActivated;
            nxR.hdcState <= InitHdc3;
         when InitHdc3 =>
            nxR.avm.addr  <= cTrfrCmdAddr;
            nxR.avm.wData(9 downto 0) <= '0' & '0' & "00010000";
            nxR.avm.write <= cActivated;
            nxR.hdcState <= Idle;
         when InitHdc4 =>
            nxR.avm.addr  <= cTrfrCmdAddr;
            nxR.avm.wData(9 downto 0) <= '0' & '1' & "00000000";
            nxR.avm.write <= cActivated;
            nxR.hdcState <= Idle;
         when Idle =>
            if reg.read = cActivated then
               nxR.hdcState <= StartMeasureTemp1;
            end if;
         when StartMeasureTemp1 =>
            nxR.avm.addr  <= cTrfrCmdAddr;
            nxR.avm.wData(9 downto 0) <= '1' & '0' & cHdcWriteAddr;
            nxR.avm.write <= cActivated;
            nxR.hdcState  <= StartMeasureTemp2;
         when StartMeasureTemp2 =>
            nxR.avm.addr  <= cTrfrCmdAddr;
            nxR.avm.wData(9 downto 0) <= '0' & '1' & "00000000";
            nxR.avm.write <= cActivated;
            nxR.hdcState <= TempWrCmd1;
         when WaitTemp1 =>
            if HdcRdySync /= '0' then
               nxR.hdcState <= WaitTemp2;
            end if;
         when WaitTemp2 =>
            if HdcRdySync = '0' then
               nxR.hdcState <= TempWrCmd1;
            end if;
         when TempWrCmd1 =>
            nxR.avm.addr  <= cTrfrCmdAddr;
            nxR.avm.wData(9 downto 0) <= '1' & '0' & cHdcWriteAddr;
            nxR.avm.write <= cActivated;
            nxR.hdcState <= TempWrCmd2;
         when TempWrCmd2 =>
            nxR.avm.addr  <= cTrfrCmdAddr;
            nxR.avm.wData(9 downto 0) <= '0' & '1' & cHdcTempAddr;
            nxR.avm.write <= cActivated;
            nxR.hdcState <= TempRdCmd1;
         when TempRdCmd1 =>
            nxR.avm.addr  <= cTrfrCmdAddr;
            nxR.avm.wData(9 downto 0) <= '1' & '0' & cHdcReadAddr;
            nxR.avm.write <= cActivated;
            nxR.hdcState <= TempRdCmd2;
         when TempRdCmd2 =>
            nxR.avm.addr  <= cTrfrCmdAddr;
            nxR.avm.wData(9 downto 8) <= '0' & '0';
            nxR.avm.write <= cActivated;
            nxR.hdcState <= TempRdCmd3;
         when TempRdCmd3 =>
            nxR.avm.addr  <= cTrfrCmdAddr;
            nxR.avm.wData(9 downto 0) <= '0' & '1' & cHdcWriteAddr;
            nxR.avm.write <= cActivated;
            nxR.hdcState <= HumWrCmd1;
         when StartMeasureHum1 =>
            nxR.avm.addr  <= cTrfrCmdAddr;
            nxR.avm.wData(9 downto 0) <= '1' & '0' & cHdcWriteAddr;
            nxR.avm.write <= cActivated;
            nxR.hdcState <= StartMeasureHum2;
         when StartMeasureHum2 =>
            nxR.avm.addr  <= cTrfrCmdAddr;
            nxR.avm.wData(9 downto 0) <= '0' & '1' & "00000001";
            nxR.avm.write <= cActivated;
            nxR.hdcState <= WaitHum1;
         when WaitHum1 =>
            if HdcRdySync /= '0' then
               nxR.hdcState <= WaitHum2;
            end if;
         when WaitHum2 =>
            if HdcRdySync = '0' then
               nxR.hdcState <= HumWrCmd1;
            end if;
         when HumWrCmd1 =>
            nxR.avm.addr  <= cTrfrCmdAddr;
            nxR.avm.wData(9 downto 0) <= '1' & '0' & cHdcWriteAddr;
            nxR.avm.write <= cActivated;
            nxR.hdcState <= HumWrCmd2;
         when HumWrCmd2 =>
            nxR.avm.addr  <= cTrfrCmdAddr;
            nxR.avm.wData(9 downto 0) <= '0' & '1' & cHdcHumAddr;
            nxR.avm.write <= cActivated;
            nxR.hdcState <= HumRdCmd1;
         when HumRdCmd1 =>
            nxR.avm.addr  <= cTrfrCmdAddr;
            nxR.avm.wData(9 downto 0) <= '1' & '0' & cHdcReadAddr;
            nxR.avm.write <= cActivated;
            nxR.hdcState <= HumRdCmd2;
         when HumRdCmd2 =>
            nxR.avm.addr  <= cTrfrCmdAddr;
            nxR.avm.wData(9 downto 8) <= '0' & '0';
            nxR.avm.write <= cActivated;
            nxR.hdcState <= HumRdCmd3;
         when HumRdCmd3 =>
            nxR.avm.addr  <= cTrfrCmdAddr;
            nxR.avm.wData(9 downto 0) <= '0' & '1' & cHdcWriteAddr;
            nxR.avm.write <= cActivated;

            nxR.avm.addr  <= cStatAddr;
            nxR.avm.read  <= cActivated;
            nxR.hdcState  <= WaitRead;
         when WaitRead =>
            nxR.avm.addr  <= cStatAddr;
            nxR.avm.read  <= cActivated;

            if unsigned(avm_m0_readdata) = 4 then
               nxR.avm.addr <= cRxDataAddr;
               nxR.avm.read <= cActivated;
               nxR.hdcState <= TmpRead1;
            end if;
         when TmpRead1 =>
            if avm_m0_waitrequest = '0' then
               nxR.valid <= cInactivated;
               nxR.shadowReg.temperature(15 downto 8) <= std_ulogic_vector(avm_m0_readdata(7 downto 0));

               nxR.avm.addr <= cRxDataAddr;
               nxR.avm.read <= cActivated;
               nxR.hdcState <= TmpRead2;
            end if;
            when TmpRead2 =>
            if avm_m0_waitrequest = '0' then
               nxR.valid <= cInactivated;
               nxR.shadowReg.temperature(7 downto 0) <= std_ulogic_vector(avm_m0_readdata(7 downto 0));

               nxR.avm.addr <= cRxDataAddr;
               nxR.avm.read <= cActivated;
               nxR.hdcState <= HumRead1;
            end if;
         when HumRead1 =>
            if avm_m0_waitrequest = '0' then
               nxR.valid <= cInactivated;
               nxR.shadowReg.humidity(15 downto 8) <= std_ulogic_vector(avm_m0_readdata(7 downto 0));

               nxR.avm.addr <= cRxDataAddr;
               nxR.avm.read <= cActivated;
               nxR.hdcState <= HumRead2;
            end if;
         when HumRead2 =>
            if avm_m0_waitrequest = '0' then
               nxR.shadowReg.humidity(7 downto 0) <= std_ulogic_vector(avm_m0_readdata(7 downto 0));
               nxR.shadowReg.timestamp <= reg.timestamp;
               nxR.hdcState <= Idle;
            end if;
         when others =>
            nxR.hdcState <= Init;
      end case;

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

   syncProc : process( iClk, inRst )
   begin
      if inRst = '0' then
         hdcRdy <= '0';
         hdcRdySync <= '0';
      elsif (rising_edge(iClk)) then
         hdcRdy <= iHdcRdy;
         hdcRdySync <= hdcRdy;
      end if;
   end process ; -- regProc

   avs_s0_readdata  <= std_logic_vector(reg.readdata);
   avm_m0_address   <= std_logic_vector(reg.avm.addr) & "00";
   avm_m0_read      <= std_logic(reg.avm.read);
   avm_m0_write     <= std_logic(reg.avm.write);
   avm_m0_writedata <= std_logic_vector(reg.avm.wData);

end architecture rtl; -- of new_component
