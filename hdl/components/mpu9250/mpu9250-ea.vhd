-- mpu92509301-ea.vhd

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

entity mpu9250 is
   generic (
      gClkFrequency    : natural := 50E6);
   port ( 
      iClk               : in  std_logic                     := '0';             -- clock.clk 
      inRst              : in  std_logic                     := '0';             -- reset.reset 
      avs_s0_address     : in  std_logic_vector( 3 downto 0) := (others => '0'); -- avs_s0.address
      avs_s0_read        : in  std_logic                     := '0';             --       .read
      avs_s0_readdata    : out std_logic_vector(31 downto 0);                    --       .readdata
      avs_s0_write       : in  std_logic                     := '0';             --       .write
      avs_s0_writedata   : in  std_logic_vector(31 downto 0) := (others => '0'); --       .writedata
      avm_m0_address     : out std_logic_vector( 5 downto 0) := (others => '0'); -- avs_m0.address
      avm_m0_read        : out std_logic                     := '0';             --       .read
      avm_m0_readdata    : in  std_logic_vector(31 downto 0);                    --       .readdata
      avm_m0_write       : out std_logic                     := '0';             --       .write
      avm_m0_writedata   : out std_logic_vector(31 downto 0) := (others => '0'); --       .writedata
      avm_m0_waitrequest : in  std_logic --       .writedata
   );
end entity mpu9250;

architecture rtl of mpu9250 is
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
   constant cSclLowAddr         : std_ulogic_vector(3 downto 0) := X"8";
   constant cSclHighAddr        : std_ulogic_vector(3 downto 0) := X"9";
   constant cSclHoldAddr        : std_ulogic_vector(3 downto 0) := X"A";

   -- I2C Addresses
   constant cMpu9250ReadAddr  : std_ulogic_vector(7 downto 0) := X"53";
   constant cMpu9250WriteAddr : std_ulogic_vector(7 downto 0) := X"52";

   -- HDC Reg Addresses
   constant cMpu9250ControlAddr        : std_ulogic_vector(3 downto 0) := X"0"; -- Enable : 0x3
   constant cMpu9250TimingAddr         : std_ulogic_vector(3 downto 0) := X"1"; -- Every 400ms : 0x2
   constant cMpu9250ThresholdLowLAddr  : std_ulogic_vector(3 downto 0) := X"2"; -- dont care
   constant cMpu9250ThresholdLowHAddr  : std_ulogic_vector(3 downto 0) := X"3"; -- dont care
   constant cMpu9250ThresholdHighLAddr : std_ulogic_vector(3 downto 0) := X"4"; -- dont care
   constant cMpu9250ThresholdHighHAddr : std_ulogic_vector(3 downto 0) := X"5"; -- dont care
   constant cnMpu9250InterruptAddr      : std_ulogic_vector(3 downto 0) := X"6"; -- Interrupt enable + every cycle: 0x10
   constant cMpu9250CRCAddr            : std_ulogic_vector(3 downto 0) := X"8"; -- dont care
   constant cMpu9250IDAddr             : std_ulogic_vector(3 downto 0) := X"A"; -- dont care
   constant cMpu9250Data0LAddr         : std_ulogic_vector(3 downto 0) := X"C"; 
   constant cMpu9250Data0HAddr         : std_ulogic_vector(3 downto 0) := X"D";
   constant cMpu9250Data1LAddr         : std_ulogic_vector(3 downto 0) := X"E";
   constant cMpu9250Data1HAddr         : std_ulogic_vector(3 downto 0) := X"F";

   -- Avalon Slave Adresses
   constant cAddrGyroX   : std_logic_vector(3 downto 0) := X"0";
   constant cAddrGyroY   : std_logic_vector(3 downto 0) := X"1";
   constant cAddrGyroZ   : std_logic_vector(3 downto 0) := X"2";
   constant cAddrAccX    : std_logic_vector(3 downto 0) := X"3";
   constant cAddrAccY    : std_logic_vector(3 downto 0) := X"4";
   constant cAddrAccZ    : std_logic_vector(3 downto 0) := X"5";
   constant cAddrMagnetX : std_logic_vector(3 downto 0) := X"6";
   constant cAddrMagnetY : std_logic_vector(3 downto 0) := X"7";
   constant cAddrMagnetZ : std_logic_vector(3 downto 0) := X"8";
   constant cAddrTsLo    : std_logic_vector(3 downto 0) := X"9";
   constant cAddrTsUp    : std_logic_vector(3 downto 0) := X"A";

   type aAvmRegSet is record
      addr  : std_ulogic_vector( 3 downto 0);
      wData : std_ulogic_vector(31 downto 0);
      write : std_ulogic;
      read  : std_ulogic;
   end record;

   constant cAvmRegSetClear : aAvmRegSet := (
      addr  => (others => '0'),
      wData => (others => '0'),
      write => cInactivated,
      read  => cInactivated
   );

   type a3dSensorValueSet is record
      x : aSensorValue;
      y : aSensorValue;
      z : aSensorValue;
   end record;

   constant c3dSensorValueSetClear : a3dSensorValueSet := (
      x => (others => '0'),
      y => (others => '0'),
      z => (others => '0')
   );

   type aValueSet is record
      timestamp : aTimestamp;
      gyro      : a3dSensorValueSet;
      acc       : a3dSensorValueSet;
      magnet    : a3dSensorValueSet;
   end record;

   constant cValueSetClear : aValueSet := (
      timestamp => (others => '0'),
      gyro      => c3dSensorValueSetClear,
      acc       => c3dSensorValueSetClear,
      magnet    => c3dSensorValueSetClear);

   type aMpu9250State is (
      Init, InitI2c1, InitI2c2, InitI2c3, InitI2c4, InitI2c5,
      InitWakeup, InitMpu92501, InitMpu92502, InitMpu92503, InitMpu92504,
      InitMpu92505, InitMpu92506, InitMpu92507, InitMpu92508, InitMpu92509,
      Idle, WakeUpI2c, WaitInt,
      WdRdAddr1, WdRdAddr2, RdCmd1, RdCmd2, RdCmd3,
      WaitRead1, WaitRead2, LightRead1, LightRead2
   );

   type aRegSet is record
      lock      : std_ulogic;
      readdata  : std_ulogic_vector(31 downto 0);
      reg       : aValueSet;
      read      : std_ulogic;
      shadowReg : aValueSet;
      avm       : aAvmRegSet;
      timestamp : aTimestamp;
      valid     : std_ulogic;
      state     : aMpu9250State;
   end record;

   constant cRegSetClear : aRegSet := (
      lock      => cInactivated,
      readdata  => (others => '0'),
      reg       => cValueSetClear,
      read      => cInactivated,
      shadowReg => cValueSetClear,
      avm       => cAvmRegSetClear,
      timestamp => (others => '0'),
      valid     => cInactivated,
      state  => Init);

   signal msTick   : std_ulogic;
   signal reg, nxR : aRegSet;
begin

   strobe : entity work.StrobeGen
   generic map (
      gClkFrequency    => gClkFrequency,
      gStrobeFrequency => cMsFrequency)
   port map (
      iClk             => iClk,
      inResetAsync     => inRst,
      oStrobe          => msTick);

   fsm : process( reg, avs_s0_read, msTick, avs_s0_address, avm_m0_readdata, avm_m0_waitrequest )
   begin
      nxR           <= reg;
      nxR.readdata  <= (others => '0');
      nxR.read      <= cInactivated;
      nxR.avm.addr  <= (others => '0');
      nxR.avm.wData <= (others => '0');
      nxR.avm.read  <= cInactivated;
      nxR.avm.write <= cInactivated;
      nxR.valid     <= cActivated;

      -- Timestamp logic
      if msTick = cActivated then
         nxR.timestamp <= reg.timestamp + 1;
      end if;

      -- Load shadow reg to actual reg
      if reg.lock = cInactivated AND reg.valid = cActivated then
         nxR.reg <= reg.shadowReg;
      end if;

      nxR.shadowReg.timestamp <= reg.timestamp;
      nxR.shadowReg.gyro.x    <= std_ulogic_vector(reg.timestamp(15 downto 0));
      nxR.shadowReg.gyro.y    <= std_ulogic_vector(reg.timestamp(15 downto 0));
      nxR.shadowReg.gyro.z    <= std_ulogic_vector(reg.timestamp(15 downto 0));
      nxR.shadowReg.acc.x     <= std_ulogic_vector(reg.timestamp(15 downto 0));
      nxR.shadowReg.acc.y     <= std_ulogic_vector(reg.timestamp(15 downto 0));
      nxR.shadowReg.acc.z     <= std_ulogic_vector(reg.timestamp(15 downto 0));
      nxR.shadowReg.magnet.x  <= std_ulogic_vector(reg.timestamp(15 downto 0));
      nxR.shadowReg.magnet.y  <= std_ulogic_vector(reg.timestamp(15 downto 0));
      nxR.shadowReg.magnet.z  <= std_ulogic_vector(reg.timestamp(15 downto 0));

--      case reg.state is
--         when Init =>
--            nxR.state <= InitI2c1;
--         when InitI2c1 =>
--            nxR.avm.addr  <= cCtrlAddr;
--            nxR.avm.wData <= (others => '0');
--            nxR.avm.write <= cActivated;
--            nxR.state     <= InitI2c2;
--         when InitI2c2 =>
--            nxR.avm.addr  <= cSclLowAddr;
--            nxR.avm.wData <= X"000000A2";
--            nxR.avm.write <= cActivated;
--            nxR.state     <= InitI2c3;
--         when InitI2c3 =>
--            nxR.avm.addr  <= cSclHighAddr;
--            nxR.avm.wData <= X"00000057";
--            nxR.avm.write <= cActivated;
--            nxR.state     <= InitI2c4;
--         when InitI2c4 =>
--            nxR.avm.addr  <= cSclHoldAddr;
--            nxR.avm.wData <= X"0000007D";
--            nxR.avm.write <= cActivated;
--            nxR.state     <= InitI2c5;
--         when InitI2c5 =>
--            nxR.avm.addr  <= cCtrlAddr;
--            nxR.avm.wData(1 downto 0) <= "11";
--            nxR.avm.write <= cActivated;
--            nxR.state     <= InitWakeup;
--         when InitWakeup =>
--            nxR.avm.addr <= cTrfrCmdAddr;
--            nxR.avm.read <= cActivated;
--            nxR.state    <= InitMpu92501;
--         when InitMpu92501 =>
--            nxR.avm.addr  <= cTrfrCmdAddr;
--            nxR.avm.wData(9 downto 0) <= '1' & '0' & cMpu9250WriteAddr;
--            nxR.avm.write <= cActivated;
--            nxR.state     <= InitMpu92502;
--         when InitMpu92502 =>
--            nxR.avm.addr  <= cTrfrCmdAddr;
--            nxR.avm.wData(9 downto 0) <= '0' & '0' & '1' & '1' & '0' & '0' & cMpu9250TimingAddr;
--            nxR.avm.write <= cActivated;
--            nxR.state  <= InitMpu92503;
--         when InitMpu92503 =>
--            nxR.avm.addr  <= cTrfrCmdAddr;
--            nxR.avm.wData(9 downto 0) <= '0' & '1' & X"02";
--            nxR.avm.write <= cActivated;
--            nxR.state  <= InitMpu92504;
--         when InitMpu92504 =>
--            nxR.avm.addr  <= cTrfrCmdAddr;
--            nxR.avm.wData(9 downto 0) <= '1' & '0' & cMpu9250WriteAddr;
--            nxR.avm.write <= cActivated;
--            nxR.state     <= InitMpu92505;
--         when InitMpu92505 =>
--            nxR.avm.addr  <= cTrfrCmdAddr;
--            nxR.avm.wData(9 downto 0) <= '0' & '0' & '1' & '1' & '0' & '0' & cnMpu9250InterruptAddr;
--            nxR.avm.write <= cActivated;
--            nxR.state  <= InitMpu92506;
--         when InitMpu92506 =>
--            nxR.avm.addr  <= cTrfrCmdAddr;
--            nxR.avm.wData(9 downto 0) <= '0' & '1' & X"10";
--            nxR.avm.write <= cActivated;
--            nxR.state  <= InitMpu92507;
--         when InitMpu92507 =>
--            nxR.avm.addr  <= cTrfrCmdAddr;
--            nxR.avm.wData(9 downto 0) <= '1' & '0' & cMpu9250WriteAddr;
--            nxR.avm.write <= cActivated;
--            nxR.state     <= InitMpu92508;
--         when InitMpu92508 =>
--            nxR.avm.addr  <= cTrfrCmdAddr;
--            nxR.avm.wData(9 downto 0) <= '0' & '0' & '1' & '1' & '0' & '0' & cMpu9250TimingAddr;
--            nxR.avm.write <= cActivated;
--            nxR.state  <= InitMpu92509;
--         when InitMpu92509 =>
--            nxR.avm.addr  <= cTrfrCmdAddr;
--            nxR.avm.wData(9 downto 0) <= '0' & '1' & X"03";
--            nxR.avm.write <= cActivated;
--            nxR.state  <= Idle;
--         when Idle =>
--            if reg.read = cActivated then
--               nxR.state <= WaitInt;
--            end if;
--         when WaitInt =>
--            if mpu9250IntSync = '0' then
--               nxR.state <= WdRdAddr1;
--               nxR.avm.addr <= cTrfrCmdAddr;
--               nxR.avm.read <= cActivated;
--            end if;
--         when WdRdAddr1 =>
--            nxR.avm.addr  <= cTrfrCmdAddr;
--            nxR.avm.wData(9 downto 0) <= '1' & '0' & cMpu9250WriteAddr;
--            nxR.avm.write <= cActivated;
--            nxR.state     <= WdRdAddr2;
--         when WdRdAddr2 =>
--            nxR.avm.addr  <= cTrfrCmdAddr;
--            nxR.avm.wData(9 downto 0) <= '0' & '0' & '1' & '1' & '1' & '0' & cMpu9250Data0LAddr;
--            nxR.avm.write <= cActivated;
--            nxR.state  <= RdCmd1;
--         when RdCmd1 =>
--            nxR.avm.addr  <= cTrfrCmdAddr;
--            nxR.avm.wData(9 downto 0) <= '1' & '0' & cMpu9250ReadAddr;
--            nxR.avm.write <= cActivated;
--            nxR.state  <= RdCmd2;
--         when RdCmd2 =>
--            nxR.avm.addr  <= cTrfrCmdAddr;
--            nxR.avm.wData(9 downto 8) <= '0' & '0';
--            nxR.avm.write <= cActivated;
--            nxR.state  <= RdCmd3;
--         when RdCmd3 =>
--            nxR.avm.addr  <= cTrfrCmdAddr;
--            nxR.avm.wData(9 downto 8) <= '0' & '1';
--            nxR.avm.write <= cActivated;
--            nxR.state  <= WaitRead1;
--         when WaitRead1 =>
--            nxR.avm.addr  <= cRxDataFifoLvlAddr;
--            nxR.avm.read  <= cActivated;
--            nxR.state  <= WaitRead2;
--
--         when WaitRead2 =>
--            nxR.avm.addr  <= cRxDataFifoLvlAddr;
--            nxR.avm.read  <= cActivated;
--
--            if avm_m0_waitrequest = cInactivated AND unsigned(avm_m0_readdata(3 downto 0)) >= 4 then
--               nxR.avm.addr <= cRxDataAddr;
--               nxR.avm.read <= cActivated;
--               nxR.state <= LightRead1;
--            end if;
--         when LightRead1 =>
--            nxR.valid    <= cInactivated;
--            nxR.avm.addr <= cRxDataAddr;
--            nxR.avm.read <= cActivated;
--            if avm_m0_waitrequest = '0' then
--               nxR.shadowReg.light(15 downto 8) <= std_ulogic_vector(avm_m0_readdata(7 downto 0));
--               nxR.state <= LightRead2;
--            end if;
--         when LightRead2 =>
--            if avm_m0_waitrequest = cInactivated then
--               nxR.shadowReg.light(7 downto 0) <= std_ulogic_vector(avm_m0_readdata(7 downto 0));
--               nxR.shadowReg.timestamp <= reg.timestamp;
--               nxR.state <= Idle;
--            else
--               nxR.valid    <= cInactivated;
--               nxR.avm.addr <= cRxDataAddr;
--               nxR.avm.read <= cActivated;
--            end if;
--         when others =>
--            nxR.state <= Init;
--      end case;

      -- Bus logic
      if avs_s0_read = cActivated then
         case( avs_s0_address ) is
            when cAddrGyroX =>
               nxR.readdata(15 downto 0) <= reg.reg.gyro.x;
               nxR.lock     <= cActivated;

            when cAddrGyroY =>
               nxR.readdata(15 downto 0) <= reg.reg.gyro.y;
               nxR.lock     <= cActivated;

            when cAddrGyroZ =>
               nxR.readdata(15 downto 0) <= reg.reg.gyro.z;
               nxR.lock     <= cActivated;

            when cAddrAccX =>
               nxR.readdata(15 downto 0) <= reg.reg.acc.x;
               nxR.lock     <= cActivated;

            when cAddrAccY =>
               nxR.readdata(15 downto 0) <= reg.reg.acc.y;
               nxR.lock     <= cActivated;

            when cAddrAccZ =>
               nxR.readdata(15 downto 0) <= reg.reg.acc.z;
               nxR.lock     <= cActivated;

            when cAddrMagnetX =>
               nxR.readdata(15 downto 0) <= reg.reg.magnet.x;
               nxR.lock     <= cActivated;

            when cAddrMagnetY =>
               nxR.readdata(15 downto 0) <= reg.reg.magnet.y;
               nxR.lock     <= cActivated;

            when cAddrMagnetZ =>
               nxR.readdata(15 downto 0) <= reg.reg.magnet.z;
               nxR.lock     <= cActivated;

            when cAddrTsLo =>
               nxR.readdata <= std_ulogic_vector(reg.reg.timestamp(31 downto 0));
               nxR.lock     <= cActivated;

            when cAddrTsUp =>
               nxR.readdata <= std_ulogic_vector(reg.reg.timestamp(63 downto 32));
               nxR.lock     <= cInactivated;

            when others =>
               null;
         end case ;
      end if;
   end process; -- fsm

   regProc : process( iClk, inRst )
   begin
      if inRst = cnActivated then
         reg <= cRegSetClear;
      elsif (rising_edge(iClk)) then
         reg <= nxR;
      end if;
   end process ; -- regProc

   avs_s0_readdata  <= std_logic_vector(reg.readdata);
   avm_m0_address   <= std_logic_vector(reg.avm.addr) & "00";
   avm_m0_read      <= std_logic(reg.avm.read);
   avm_m0_write     <= std_logic(reg.avm.write);
   avm_m0_writedata <= std_logic_vector(reg.avm.wData);

end architecture rtl; -- of new_component
