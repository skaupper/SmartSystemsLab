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
      avm_m0_waitrequest : in  std_logic;--       .writedata
      iSpiTxReady        : in  std_logic; --       .writedata
      inMpuInt           : in  std_logic --       .writedata
   );
end entity mpu9250;

architecture rtl of mpu9250 is
   constant cTimestampWidth : natural := 64;
   subtype aTimestamp is unsigned (cTimestampWidth-1 downto 0);

   constant cMsFrequency : natural := 1E3;
   
   constant cSensorCount : natural := 9;
   constant cSensorValueWidth : natural := 16;
   subtype aSensorValue is std_ulogic_vector (cSensorValueWidth-1 downto 0);
   type aSensorValues is array (0 to cSensorCount) of aSensorValue;

   -- I2C Avalon Adresses
   constant cRxDataAddr   : std_ulogic_vector(3 downto 0) := X"0";
   constant cTxDataAddr   : std_ulogic_vector(3 downto 0) := X"1";
   constant cStatusAddr   : std_ulogic_vector(3 downto 0) := X"2";
   constant cControlAddr  : std_ulogic_vector(3 downto 0) := X"3"; -- 0x40
   constant cSlaveSelAddr : std_ulogic_vector(3 downto 0) := X"5";
   constant cEopValueAddr : std_ulogic_vector(3 downto 0) := X"6";

   -- MPU Reg Addresses
   constant cMpuSmplrtDiv        : std_ulogic_vector(7 downto 0) := X"19"; -- 0x00
   constant cMpuConfig           : std_ulogic_vector(7 downto 0) := X"1A"; -- 0x01
   constant cMpuGyroConfig       : std_ulogic_vector(7 downto 0) := X"1B"; -- 0x00
   constant cMpuAccelConfig      : std_ulogic_vector(7 downto 0) := X"1C"; -- 0x00
   constant cMpuAccelConfig2     : std_ulogic_vector(7 downto 0) := X"1D"; -- 0x01
   --constant cMpuI2cMasterCtrl    : std_ulogic_vector(7 downto 0) := X"24"; -- 0b1101 & 0xD
   --constant cMpuI2cSlv0Addr      : std_ulogic_vector(7 downto 0) := X"25";
   --constant cMpuI2cSlv0Reg       : std_ulogic_vector(7 downto 0) := X"26";
   --constant cMpuI2cSlv0Ctrl      : std_ulogic_vector(7 downto 0) := X"26"; -- 0b100
   constant cMpuIntPinCfg     : std_ulogic_vector(7 downto 0) := X"37"; -- 0b10110000
   constant cMpuIntEnable     : std_ulogic_vector(7 downto 0) := X"38"; -- 0b00000001
   constant cMpuIntStatus     : std_ulogic_vector(7 downto 0) := X"3A";
   constant cMpuAccelXH       : std_ulogic_vector(7 downto 0) := X"3B";
   constant cMpuAccelXL       : std_ulogic_vector(7 downto 0) := X"3C";
   constant cMpuAccelYH       : std_ulogic_vector(7 downto 0) := X"3D";
   constant cMpuAccelYL       : std_ulogic_vector(7 downto 0) := X"3E";
   constant cMpuAccelZH       : std_ulogic_vector(7 downto 0) := X"3F";
   constant cMpuAccelZL       : std_ulogic_vector(7 downto 0) := X"40";
   constant cMpuGyroXH        : std_ulogic_vector(7 downto 0) := X"43";
   constant cMpuGyroXL        : std_ulogic_vector(7 downto 0) := X"44";
   constant cMpuGyroYH        : std_ulogic_vector(7 downto 0) := X"45";
   constant cMpuGyroYL        : std_ulogic_vector(7 downto 0) := X"46";
   constant cMpuGyroZH        : std_ulogic_vector(7 downto 0) := X"47";
   constant cMpuGyroZL        : std_ulogic_vector(7 downto 0) := X"48";
   constant cMpuUserControl   : std_ulogic_vector(7 downto 0) := X"6A"; -- 0b00110000
   constant cMpuPwrMgmt1      : std_ulogic_vector(7 downto 0) := X"6B"; -- 0b00000001

   -- I2C Magnetometer Address
   constant cAk8963ReadAddr   : std_ulogic_vector(7 downto 0) := X"19";
   constant cAk8963WriteAddr  : std_ulogic_vector(7 downto 0) := X"18";

   -- I2C Magnetometer Reg Addresses
   constant cAkStatus      : std_ulogic_vector(7 downto 0) := X"02";
   constant cAkDataXL      : std_ulogic_vector(7 downto 0) := X"03";
   constant cAkDataXH      : std_ulogic_vector(7 downto 0) := X"04";
   constant cAkDataYL      : std_ulogic_vector(7 downto 0) := X"05";
   constant cAkDataYH      : std_ulogic_vector(7 downto 0) := X"06";
   constant cAkDatazL      : std_ulogic_vector(7 downto 0) := X"07";
   constant cAkDatazH      : std_ulogic_vector(7 downto 0) := X"08";
   constant cAkControl1    : std_ulogic_vector(7 downto 0) := X"0A"; -- 0x16

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

   type aMpuCmd is record
      read : std_ulogic;
      addr : std_ulogic_vector(7 downto 0);
      data : std_ulogic_vector(7 downto 0);
   end record;

   function createTxAddr(cmd : aMpuCmd) return std_ulogic_vector is
   begin
      return cmd.read & cmd.addr(6 downto 0);
   end createTxAddr;

   type aMpuCmdArr is array (natural range <>) of aMpuCmd;

   constant cMpuInit : aMpuCmdArr := (
      (read => '0', addr => cMpuPwrMgmt1,     data => X"01"),
      (read => '0', addr => cMpuUserControl,  data => X"30"),
      (read => '0', addr => cMpuSmplrtDiv,    data => X"00"),
      (read => '0', addr => cMpuConfig,       data => X"01"),
      (read => '0', addr => cMpuGyroConfig,   data => X"00"),
      (read => '0', addr => cMpuAccelConfig,  data => X"00"),
      (read => '0', addr => cMpuAccelConfig2, data => X"01"),
      (read => '0', addr => cMpuIntPinCfg,    data => X"B0"),
      (read => '0', addr => cMpuIntEnable,    data => X"01")
   );

   constant cMpuRead : aMpuCmdArr := (
      (read => '1', addr => cMpuAccelXH, data => X"00"),
      (read => '1', addr => cMpuAccelXL, data => X"00"),
      (read => '1', addr => cMpuAccelYH, data => X"00"),
      (read => '1', addr => cMpuAccelYL, data => X"00"),
      (read => '1', addr => cMpuAccelZH, data => X"00"),
      (read => '1', addr => cMpuAccelZL, data => X"00"),
      (read => '1', addr => cMpuGyroXH,  data => X"00"),
      (read => '1', addr => cMpuGyroXL,  data => X"00"),
      (read => '1', addr => cMpuGyroYH,  data => X"00"),
      (read => '1', addr => cMpuGyroYL,  data => X"00"),
      (read => '1', addr => cMpuGyroZH,  data => X"00"),
      (read => '1', addr => cMpuGyroZL,  data => X"00")
   );

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

   type aValueSet is record
      timestamp : aTimestamp;
      data      : aSensorValues;
   end record;

   constant cValueSetClear : aValueSet := (
      timestamp => (others => '0'),
      data      => (others => (others => '0')));

   type aMpu9250State is (
      Init, InitInterrupt, InitMpu,
      WaitData, ReadData);

   type aSpiState is (Address, Data, WaitRead1, WaitRead2, Read);

   type aSpiReg is record
      idx   : natural;
      state : aSpiState;
   end record;

   constant cSpiRegClear : aSpiReg := (
      idx   => 0,
      state => Address);

   type aRegSet is record
      lock      : std_ulogic;
      readdata  : std_ulogic_vector(31 downto 0);
      reg       : aValueSet;
      shadowReg : aValueSet;
      avm       : aAvmRegSet;
      timestamp : aTimestamp;
      valid     : std_ulogic;
      state     : aMpu9250State;
      spi       : aSpiReg;
   end record;

   constant cRegSetClear : aRegSet := (
      lock      => cInactivated,
      readdata  => (others => '0'),
      reg       => cValueSetClear,
      shadowReg => cValueSetClear,
      avm       => cAvmRegSetClear,
      timestamp => (others => '0'),
      valid     => cInactivated,
      state     => Init,
      spi       => cSpiRegClear);

   signal nMpuInt, nMpuIntSync : std_ulogic;
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

   fsm : process( reg, avs_s0_read, msTick, avs_s0_address, avm_m0_readdata,
                  avm_m0_waitrequest,iSpiTxReady, nMpuInt )
   begin
      nxR           <= reg;
      nxR.readdata  <= (others => '0');
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

      nxR.shadowReg.data(6)   <= std_ulogic_vector(reg.timestamp(15 downto 0));
      nxR.shadowReg.data(7)   <= std_ulogic_vector(reg.timestamp(15 downto 0));
      nxR.shadowReg.data(8)   <= std_ulogic_vector(reg.timestamp(15 downto 0));

      case reg.state is
         when Init =>
            nxR.state <= InitInterrupt;
         when InitInterrupt =>
            nxR.avm.addr  <= cControlAddr;
            nxR.avm.wData(6) <= cActivated;
            nxR.avm.write <= cActivated;
            nxR.spi.state <= Address;
            nxR.spi.idx   <= cMpuInit'low;
            nxR.state     <= InitMpu;
         when InitMpu =>
            if iSpiTxReady = cActivated then
               nxR.avm.addr  <= cTxDataAddr;

               case reg.spi.state is
                  when Address =>
                     nxR.avm.wData(7 downto 0) <= createTxAddr(cMpuInit(reg.spi.idx));
                     nxR.avm.write <= cActivated;
                     nxR.spi.state <= Data;
                  when Data =>
                     nxR.avm.wData(7 downto 0) <= cMpuInit(reg.spi.idx).data;
                     nxR.avm.write <= cActivated;
                     nxR.spi.state <= Address;
                     if reg.spi.idx = cMpuInit'high then
                        nxR.state <= WaitData;
                     else
                        nxR.spi.idx <= reg.spi.idx + 1;
                     end if;
                  when others =>
                     nxR.state <= Init;   --ERROR
               end case ;
            end if;

         when WaitData =>
            if nMpuInt = '0' then
               nxR.valid     <= cInactivated;
               nxR.state     <= ReadData;
               -- discard rxread
               nxR.avm.addr  <= cRxDataAddr;
               nxR.avm.read  <= cActivated;
               nxR.spi.state <= Address;
               nxR.spi.idx   <= 0;
               nxR.shadowreg.timestamp <= reg.timestamp;
            end if;
         when ReadData =>
               nxR.valid     <= cInactivated;

               case reg.spi.state is
                  when Address =>
                     if iSpiTxReady = cActivated then
                        nxR.avm.addr  <= cTxDataAddr;
                        nxR.avm.wData(7 downto 0) <= createTxAddr(cMpuRead(reg.spi.idx));
                        nxR.avm.write <= cActivated;
                        nxR.spi.state <= WaitRead1;
                     end if;
                  when WaitRead1 =>
                     nxR.avm.read <= cActivated;
                     nxR.avm.addr <= cStatusAddr;
                     nxR.spi.state <= WaitRead2;

                  when WaitRead2 =>
                     nxR.avm.read <= cActivated;

                     if avm_m0_waitrequest = cInactivated AND avm_m0_readdata(7) = cActivated then
                        nxR.avm.addr  <= cRxDataAddr;
                        nxR.spi.state <= Read;
                     else
                        nxR.avm.addr <= cStatusAddr;
                     end if;

                  when Read =>

                     if avm_m0_waitrequest = cInactivated AND avm_m0_readdata(7) = cActivated then
                        if (reg.spi.idx mod 2) = 0 then
                           nxR.shadowreg.data(reg.spi.idx/2)(15 downto 8) <= std_ulogic_vector(avm_m0_readdata(7 downto 0));
                        else
                           nxR.shadowreg.data(reg.spi.idx/2)( 7 downto 0) <= std_ulogic_vector(avm_m0_readdata(7 downto 0));
                        end if;

                        if reg.spi.idx = cMpuRead'high then
                           nxR.state <= WaitData;
                        else
                           nxR.spi.state <= Address;
                           nxR.spi.idx <= reg.spi.idx + 1;
                        end if;
                     else
                        nxR.avm.addr <= cRxDataAddr;
                     end if;
                     
                  when others =>
                     nxR.state <= Init;   --ERROR
               end case ;
         when others =>
            nxR.state <= Init;
      end case;

      -- Bus logic
      if avs_s0_read = cActivated then
         case( avs_s0_address ) is
            when cAddrGyroX =>
               nxR.readdata(15 downto 0) <= reg.reg.data(0);
               nxR.lock     <= cActivated;

            when cAddrGyroY =>
               nxR.readdata(15 downto 0) <= reg.reg.data(1);
               nxR.lock     <= cActivated;

            when cAddrGyroZ =>
               nxR.readdata(15 downto 0) <= reg.reg.data(2);
               nxR.lock     <= cActivated;

            when cAddrAccX =>
               nxR.readdata(15 downto 0) <= reg.reg.data(3);
               nxR.lock     <= cActivated;

            when cAddrAccY =>
               nxR.readdata(15 downto 0) <= reg.reg.data(4);
               nxR.lock     <= cActivated;

            when cAddrAccZ =>
               nxR.readdata(15 downto 0) <= reg.reg.data(5);
               nxR.lock     <= cActivated;

            when cAddrMagnetX =>
               nxR.readdata(15 downto 0) <= reg.reg.data(6);
               nxR.lock     <= cActivated;

            when cAddrMagnetY =>
               nxR.readdata(15 downto 0) <= reg.reg.data(7);
               nxR.lock     <= cActivated;

            when cAddrMagnetZ =>
               nxR.readdata(15 downto 0) <= reg.reg.data(8);
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
      if inRst = cResetActive then
         reg <= cRegSetClear;
      elsif (rising_edge(iClk)) then
         reg <= nxR;
      end if;
   end process ; -- regProc

   syncProc : process( iClk, inRst )
   begin
      if inRst = cnActivated then
         nMpuInt     <= '1';
         nMpuIntSync <= '1';
      elsif (rising_edge(iClk)) then
         nMpuInt     <= inMpuInt;
         nMpuIntSync <= nMpuInt;
      end if;
   end process ; -- regProc

   avs_s0_readdata  <= std_logic_vector(reg.readdata);
   avm_m0_address   <= std_logic_vector(reg.avm.addr) & "00";
   avm_m0_read      <= std_logic(reg.avm.read);
   avm_m0_write     <= std_logic(reg.avm.write);
   avm_m0_writedata <= std_logic_vector(reg.avm.wData);

end architecture rtl; -- of new_component
