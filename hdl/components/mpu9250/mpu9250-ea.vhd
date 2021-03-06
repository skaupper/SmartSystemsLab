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

-- Register Map
-- - 0 -> Gyro X (16 Bit)
-- - 1 -> Gyro Y (16 Bit)
-- - 2 -> Gyro Z (16 Bit)
-- - 3 -> Acc  X (16 Bit)
-- - 4 -> Acc  Y (16 Bit)
-- - 5 -> Acc  Z (16 Bit)
-- - 6 -> Mag  X (16 Bit)
-- - 7 -> Mag  Y (16 Bit)
-- - 8 -> Mag  Z (16 Bit)
-- - 9 -> lower word of timestamp
-- - A -> upper word of timestamp
-- - B -> Buffer CTRL + Data available
--     - 0 -> Buffer 0 enable (cleared on every interrupt)
--     - 1 -> Buffer 0 data available (read only)
--     - 2 -> Buffer 1 enable (cleared on every interrupt)
--     - 3 -> Buffer 1 data available (read only)
--     - ...
-- - C -> IEN (Interrupt enable)
--     - 0 -> Buf0 Interrupt enable
--     - 1 -> Buf1 Interrupt enable
--     - ...
-- - D -> ISR (Interrupt status register, write '1' to clear Interrupt)
--     - 0 -> Buf0 Interrupt
--     - 1 -> Buf1 Interrupt
--     - ...
-- - E -> select buffer to use
-- - F -> Buffer data: reading alternates between x, y and z

entity mpu9250 is
   generic (
      gClkFrequency  : natural := 50E6;
      gPreShockCount : natural := 256);
   port ( 
      iClk               : in  std_logic                     := '0';             -- clock.clk 
      inRst              : in  std_logic                     := '0';             -- reset.reset 
      avs_s0_address     : in  std_logic_vector( 3 downto 0) := (others => '0'); -- avs_s0.address
      avs_s0_read        : in  std_logic                     := '0';             --       .read
      avs_s0_readdata    : out std_logic_vector(31 downto 0);                    --       .readdata
      avs_s0_write       : in  std_logic                     := '0';             --       .write
      avs_s0_writedata   : in  std_logic_vector(31 downto 0) := (others => '0'); --       .writedata
      irq_irq            : out std_logic;
      sclk, mosi         : out std_logic;
      miso               : in  std_logic;
      ss_n               : out std_logic_vector(0 downto 0);
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
   type aSensorValues is array (0 to cSensorCount-1) of aSensorValue;


   -- MPU Reg Addresses
   constant cMpuSmplrtDiv     : std_ulogic_vector(7 downto 0) := X"19"; -- 0x00
   constant cMpuConfig        : std_ulogic_vector(7 downto 0) := X"1A"; -- 0x01
   constant cMpuGyroConfig    : std_ulogic_vector(7 downto 0) := X"1B"; -- 0x00
   constant cMpuAccelConfig   : std_ulogic_vector(7 downto 0) := X"1C"; -- 0x00
   constant cMpuAccelConfig2  : std_ulogic_vector(7 downto 0) := X"1D"; -- 0x01
   constant cMpuI2cMasterCtrl : std_ulogic_vector(7 downto 0) := X"24"; -- 0b1101 & 0xD
   constant cMpuI2cSlv0Addr   : std_ulogic_vector(7 downto 0) := X"25";
   constant cMpuI2cSlv0Reg    : std_ulogic_vector(7 downto 0) := X"26";
   constant cMpuI2cSlv0Ctrl   : std_ulogic_vector(7 downto 0) := X"27"; -- 0b100
   constant cMpuI2cSlv0D0     : std_ulogic_vector(7 downto 0) := X"63";
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
   constant cMpuPwrMgmt2      : std_ulogic_vector(7 downto 0) := X"6C"; -- 0b00000001
   constant cMpuSlv0Dat0      : std_ulogic_vector(7 downto 0) := X"49";
   constant cMpuSlv0Dat1      : std_ulogic_vector(7 downto 0) := X"4A";
   constant cMpuSlv0Dat2      : std_ulogic_vector(7 downto 0) := X"4B";
   constant cMpuSlv0Dat3      : std_ulogic_vector(7 downto 0) := X"4C";
   constant cMpuSlv0Dat4      : std_ulogic_vector(7 downto 0) := X"4D";
   constant cMpuSlv0Dat5      : std_ulogic_vector(7 downto 0) := X"4E";

   -- I2C Magnetometer Address
   constant cAk8963ReadAddr   : std_ulogic_vector(7 downto 0) := X"8C";
   constant cAk8963WriteAddr  : std_ulogic_vector(7 downto 0) := X"0C";

   -- I2C Magnetometer Reg Addresses
   constant cAkStatus         : std_ulogic_vector(7 downto 0) := X"02";
   constant cAkDataXL         : std_ulogic_vector(7 downto 0) := X"03";
   constant cAkDataXH         : std_ulogic_vector(7 downto 0) := X"04";
   constant cAkDataYL         : std_ulogic_vector(7 downto 0) := X"05";
   constant cAkDataYH         : std_ulogic_vector(7 downto 0) := X"06";
   constant cAkDatazL         : std_ulogic_vector(7 downto 0) := X"07";
   constant cAkDatazH         : std_ulogic_vector(7 downto 0) := X"08";
   constant cAkControl1       : std_ulogic_vector(7 downto 0) := X"0A"; -- 0x16
   constant cAkControl2       : std_ulogic_vector(7 downto 0) := X"0B";

   -- Avalon Slave Adresses
   constant cAddrGyroX        : std_logic_vector(3 downto 0) := X"0";
   constant cAddrGyroY        : std_logic_vector(3 downto 0) := X"1";
   constant cAddrGyroZ        : std_logic_vector(3 downto 0) := X"2";
   constant cAddrAccX         : std_logic_vector(3 downto 0) := X"3";
   constant cAddrAccY         : std_logic_vector(3 downto 0) := X"4";
   constant cAddrAccZ         : std_logic_vector(3 downto 0) := X"5";
   constant cAddrMagnetX      : std_logic_vector(3 downto 0) := X"6";
   constant cAddrMagnetY      : std_logic_vector(3 downto 0) := X"7";
   constant cAddrMagnetZ      : std_logic_vector(3 downto 0) := X"8";
   constant cAddrTsLo         : std_logic_vector(3 downto 0) := X"9";
   constant cAddrTsUp         : std_logic_vector(3 downto 0) := X"A";
   constant cAddrCtrlAvail    : std_logic_vector(3 downto 0) := X"B";
   constant cAddrIntEn        : std_logic_vector(3 downto 0) := X"C";
   constant cAddrIntStatReg   : std_logic_vector(3 downto 0) := X"D";
   constant cAddrShockLvl     : std_logic_vector(3 downto 0) := X"E";
   constant cAddrBufData      : std_logic_vector(3 downto 0) := X"F";

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
      (read => '0', addr => cMpuUserControl,   data => X"30"), -- p.40
      (read => '0', addr => cMpuPwrMgmt1,      data => X"01"), -- p.40
      (read => '0', addr => cMpuPwrMgmt2,      data => X"00"), -- p.42
      (read => '0', addr => cMpuConfig,        data => X"01"), -- p.12
      (read => '0', addr => cMpuGyroConfig,    data => X"18"), -- p.14
      (read => '0', addr => cMpuAccelConfig,   data => X"0C"), -- p.14
      (read => '0', addr => cMpuAccelConfig2,  data => X"00"), -- p.15
      (read => '0', addr => cMpuIntPinCfg,     data => X"30"), -- p.29
      (read => '0', addr => cMpuI2cMasterCtrl, data => X"4D"), -- p.18, maybe 0x4D
      (read => '0', addr => cMpuI2cSlv0Addr,   data => cAk8963WriteAddr), -- p.20
      (read => '0', addr => cMpuI2cSlv0Reg,    data => cAkControl2), -- p.47
      (read => '0', addr => cMpuI2cSlv0D0,     data => X"01"), -- p.52
      (read => '0', addr => cMpuI2cSlv0Ctrl,   data => X"81"), -- p.20
      (read => '0', addr => cMpuI2cSlv0Reg,    data => cAkControl1), -- p.47
      (read => '0', addr => cMpuI2cSlv0D0,     data => X"16"), -- p.51
      (read => '0', addr => cMpuI2cSlv0Ctrl,   data => X"81"), -- p.20
      (read => '0', addr => cMpuI2cSlv0Addr,   data => cAk8963ReadAddr), -- p.20
      (read => '0', addr => cMpuI2cSlv0Reg,    data => cAkDataXL), -- p.47
      (read => '0', addr => cMpuI2cSlv0D0,     data => X"00"), -- p.52
      (read => '0', addr => cMpuI2cSlv0Ctrl,   data => X"D7"), -- p.20
      (read => '0', addr => cMpuIntEnable,     data => X"01")  -- p.29
   );

   constant cMagInit : aMpuCmdArr := (
      (read => '0', addr => cMpuI2cSlv0Addr,   data => cAk8963WriteAddr), -- p.20
      (read => '0', addr => cMpuI2cSlv0Reg,    data => cAkControl2), -- p.47
      (read => '0', addr => cMpuI2cSlv0D0,     data => X"01"), -- p.52
      (read => '0', addr => cMpuI2cSlv0Ctrl,   data => X"81"), -- p.20
      (read => '0', addr => cMpuI2cSlv0Addr,   data => cAk8963WriteAddr), -- p.20
      (read => '0', addr => cMpuI2cSlv0Reg,    data => cAkControl1), -- p.47
      (read => '0', addr => cMpuI2cSlv0D0,     data => X"16"), -- p.51
      (read => '0', addr => cMpuI2cSlv0Ctrl,   data => X"81"), -- p.20
      (read => '0', addr => cMpuI2cSlv0Addr,   data => cAk8963ReadAddr), -- p.20
      (read => '0', addr => cMpuI2cSlv0Reg,    data => cAkDataXL), -- p.47
      (read => '0', addr => cMpuI2cSlv0D0,     data => X"00"), -- p.52
      (read => '0', addr => cMpuI2cSlv0Ctrl,   data => X"D7") -- p.20
   );

   constant cMpuRead : aMpuCmdArr := (
      (read => '1', addr => cMpuGyroXH,   data => X"00"),
      (read => '1', addr => cMpuGyroYH,   data => X"00"),
      (read => '1', addr => cMpuGyroZH,   data => X"00"),
      (read => '1', addr => cMpuAccelXH,  data => X"00"),
      (read => '1', addr => cMpuAccelYH,  data => X"00"),
      (read => '1', addr => cMpuAccelZH,  data => X"00"),
      (read => '1', addr => cMpuSlv0Dat0, data => X"00"),
      (read => '1', addr => cMpuSlv0Dat2, data => X"00"),
      (read => '1', addr => cMpuSlv0Dat4, data => X"00"));

   type aValueSet is record
      timestamp : aTimestamp;
      data      : aSensorValues;
   end record;

   constant cValueSetClear : aValueSet := (
      timestamp => (others => '0'),
      data      => (others => (others => '0')));

   type aRamCtrl is record
      rAddr : unsigned(9 downto 0);
      wAddr : unsigned(9 downto 0);
      write : std_ulogic;
   end record;

   constant cRamCtrlClear : aRamCtrl := (
      rAddr => (others => '0'),
      wAddr => (others => '0'),
      write => cInactivated);

   type aRamState is (Idle, WaitShock, RecShock);
   type aRamWriteState is (Idle, IncAddr);
   type aRamReadState is (AccX,  AccY,  AccZ,
                          GyroX, GyroY, GyroZ,
                          MagX,  MagY,  MagZ,
                          TimeL, TimeH);

   function RamStateToULogic (s : aRamState) return std_ulogic is
   begin
      if s = Idle then
         return cInactivated;
      else
         return cActivated;
      end if;
   end function;

   type aRamReg is record
      state  : aRamState;
      wState : aRamWriteState;
      rState : aRamReadState;
      rInc   : std_ulogic;
      intEn  : std_ulogic;
      int    : std_ulogic;
      avail  : std_ulogic;
      ctrl   : aRamCtrl;
   end record;

   constant cRamRegClear : aRamReg := (
      state  => Idle,
      wState => Idle,
      rState => AccX,
      rInc   => cActivated,
      intEn  => cInactivated,
      int    => cInactivated,
      avail  => cInactivated,
      ctrl   => cRamCtrlClear);

   type aMpu9250State is (Init, InitMpu, InitMag, WaitData,
                          ReadData);

   constant cSpiFreq   : integer := 1E6;
   constant cSpiClkDiv : integer := integer(real(gClkFrequency)/real(2*cSpiFreq));

   type aSpiState is (Start, WriteAddr, WaitBusy1, WaitNBusy1,
                      WaitBusy2, WaitNBusy2);

   type aSpiIn is record
      ena    : std_ulogic;
      cont   : std_ulogic;
      txdata : std_ulogic_vector(7 downto 0);
   end record;

   constant cSpiInClear : aSpiIn := (
      ena    => '0',
      cont   => '0',
      txdata => (others => '0'));

   type aSpiOut is record
      busy   : std_logic;
      rxdata : std_logic_vector(7 downto 0);
   end record;

   type aSpiReg is record
      input : aSpiIn;
      idx   : natural;
      cnt   : natural;
      state : aSpiState;
   end record;

   constant cSpiRegClear : aSpiReg := (
      input => cSpiInClear,
      idx   => 0,
      cnt   => 0,
      state => WriteAddr);

   type aRegSet is record
      lock       : std_ulogic;
      shockLevel : aSensorValue;
      readdata   : std_ulogic_vector(31 downto 0);
      reg        : aValueSet;
      shadowReg  : aValueSet;
      timestamp  : aTimestamp;
      valid      : std_ulogic;
      state      : aMpu9250State;
      spi        : aSpiReg;
      ram        : aRamReg;
      newData    : std_ulogic;
   end record;

   constant cRegSetClear : aRegSet := (
      lock       => cInactivated,
      shockLevel => std_ulogic_vector(to_signed(10E3, cSensorValueWidth)),
      readdata   => (others => '0'),
      reg        => cValueSetClear,
      shadowReg  => cValueSetClear,
      timestamp  => (others => '0'),
      valid      => cInactivated,
      state      => Init,
      spi        => cSpiRegClear,
      ram        => cRamRegClear,
      newData    => cInactivated);

   signal spiOut   : aSpiOut;
   signal msTick   : std_ulogic;
   signal reg, nxR : aRegSet;
   signal ramWData : std_ulogic_vector(255 downto 0);
   signal ramRData : std_logic_vector(255 downto 0);
   signal nMpuInt, nMpuIntSync : std_ulogic;
begin

   strobe : entity work.StrobeGen
   generic map (
      gClkFrequency    => gClkFrequency,
      gStrobeFrequency => cMsFrequency)
   port map (
      iClk             => iClk,
      inResetAsync     => inRst,
      oStrobe          => msTick);

   spi : entity work.spi_master
   generic map (
      slaves  => 1,
      d_width => 8)
   port map (
      clock   => iClk,
      reset_n => inRst,
      enable  => std_logic(reg.spi.input.ena),
      cpol    => '1',
      cpha    => '1',
      cont    => std_logic(reg.spi.input.cont),
      clk_div => cSpiClkDiv,
      addr    => 0,
      tx_data => std_logic_vector(reg.spi.input.txdata),
      miso    => miso,
      sclk    => sclk,
      ss_n    => ss_n,
      mosi    => mosi,
      busy    => spiOut.busy,
      rx_data => spiOut.rxdata);

   ram_inst : entity work.ram port map (
      clock	    => iClk,
      data      => std_logic_vector(ramWData),
      rdaddress => std_logic_vector(reg.ram.ctrl.rAddr),
      wraddress => std_logic_vector(reg.ram.ctrl.wAddr),
      wren      => reg.ram.ctrl.write,
      q         => ramRData);

   fsm : process( reg, msTick, nMpuIntSync, spiOut, ramRData,
                  avs_s0_read, avs_s0_address, avs_s0_write, avs_s0_writedata )
      variable vRAddr : unsigned(9 downto 0);
   begin
      nxR           <= reg;
      nxR.readdata  <= (others => '0');
      nxR.valid     <= cActivated;
      nxR.newData   <= cInactivated;
      nxR.spi.input <= cSpiInClear;
      nxR.ram.ctrl.write <= cInactivated;
      nxR.ram.rInc  <= cActivated;

      -- Timestamp logic
      if msTick = cActivated then
         nxR.timestamp <= reg.timestamp + 1;
      end if;

      -- Load shadow reg to actual reg
      if reg.lock = cInactivated AND reg.valid = cActivated then
         nxR.reg <= reg.shadowReg;
      end if;

      case reg.state is
         when Init =>
            nxR.state     <= InitMpu;
            nxR.spi.state <= Start;
         when InitMpu =>
            case reg.spi.state is
               when Start =>
                  nxR.spi.state <= WriteAddr;
               when WriteAddr =>
                  if spiOut.busy = cInactivated then
                     nxR.spi.input.txdata <= createTxAddr(cMpuInit(reg.spi.idx));
                     nxR.spi.input.ena    <= cActivated;
                     nxR.spi.state        <= WaitBusy1;
                  end if;
               when WaitBusy1 =>
                  if spiOut.busy = cActivated then
                     nxR.spi.state <= WaitNBusy1;
                  end if;
               when WaitNBusy1 =>
                  nxR.spi.input.cont   <= cActivated;
                  nxR.spi.input.txdata <= cMpuInit(reg.spi.idx).data;
                  if spiOut.busy = cInactivated then
                     nxR.spi.state <= WaitBusy2;
                  end if;
               when WaitBusy2 =>
                  if spiOut.busy = cActivated then
                     nxR.spi.state <= Start;
                     if reg.spi.idx = cMpuInit'high then
                        nxR.state     <= InitMag;
                        nxR.spi.idx   <= 0;
                        nxR.spi.cnt   <= 0;
                     else
                        nxR.spi.idx   <= reg.spi.idx + 1;
                     end if;
                  end if;
               when others =>
                  nxR.state <= Init;   --ERROR
            end case;
         when InitMag =>
            case reg.spi.state is
               when Start =>
                  if mstick = cActivated then
                     nxR.spi.state <= WriteAddr;
                  end if;
               when WriteAddr =>
                  if spiOut.busy = cInactivated then
                     nxR.spi.input.txdata <= createTxAddr(cMagInit(reg.spi.idx));
                     nxR.spi.input.ena    <= cActivated;
                     nxR.spi.state        <= WaitBusy1;
                  end if;
               when WaitBusy1 =>
                  if spiOut.busy = cActivated then
                     nxR.spi.state <= WaitNBusy1;
                  end if;
               when WaitNBusy1 =>
                  nxR.spi.input.cont   <= cActivated;
                  nxR.spi.input.txdata <= cMagInit(reg.spi.idx).data;
                  if spiOut.busy = cInactivated then
                     nxR.spi.state <= WaitBusy2;
                  end if;
               when WaitBusy2 =>
                  if spiOut.busy = cActivated then
                     nxR.spi.idx   <= reg.spi.idx + 1;

                     if reg.spi.cnt = 3 then
                        nxR.spi.state <= Start;
                        nxR.spi.cnt   <= 0;

                        if reg.spi.idx = cMagInit'high then
                           nxR.state     <= WaitData;
                        end if;
                     else
                        nxR.spi.cnt   <= reg.spi.cnt + 1;
                        nxR.spi.state <= WriteAddr;
                     end if;
                  end if;
               when others =>
                  nxR.state <= Init;   --ERROR
            end case;

         when WaitData =>
            if nMpuIntSync = '1' then
               nxR.valid     <= cInactivated;
               nxR.state     <= ReadData;
               nxR.spi.state <= WriteAddr;
               nxR.spi.idx   <= 0;
               nxR.shadowreg.timestamp <= reg.timestamp;
            end if;
         when ReadData =>
            nxR.valid <= cInactivated;

            case reg.spi.state is
               when WriteAddr =>
                  if spiOut.busy = cInactivated then
                     nxR.spi.input.txdata <= createTxAddr(cMpuRead(reg.spi.idx));
                     nxR.spi.input.ena    <= cActivated;
                     nxR.spi.state        <= WaitBusy1;
                     nxR.spi.cnt          <= 0;
                  end if;
               when WaitBusy1 =>
                  if spiOut.busy = cActivated then
                     nxR.spi.state <= WaitNBusy1;
                  end if;
               when WaitNBusy1 =>
                  nxR.spi.input.cont   <= cActivated;
                  nxR.spi.input.txdata <= X"00";
                  if spiOut.busy = cInactivated then
                     nxR.spi.state     <= WaitBusy2;
                  end if;
               when WaitBusy2 =>
                  if spiOut.busy = cActivated then
                     nxR.spi.state <= WaitNBusy2;
                  end if;
               when WaitNBusy2 =>
                  if reg.spi.cnt /= 1 then
                     nxR.spi.input.cont   <= cActivated;
                     nxR.spi.input.txdata <= X"00";
                  end if;   
                  if spiOut.busy = cInactivated then
                     if reg.spi.cnt /= 1 then
                        nxR.shadowreg.data(reg.spi.idx)(15 downto 8) <= std_ulogic_vector(spiOut.rxdata);
                        nxR.spi.cnt   <= reg.spi.cnt + 1;
                        nxR.spi.state <= WaitBusy2;
                     else
                        nxR.shadowreg.data(reg.spi.idx)( 7 downto 0) <= std_ulogic_vector(spiOut.rxdata);

                        if reg.spi.idx = cMpuRead'high then
                           nxR.newData <= cActivated;
                           nxR.state   <= WaitData;
                        else
                           nxR.spi.idx   <= reg.spi.idx + 1;
                           nxR.spi.state <= WriteAddr;
                        end if;
                     end if;
                  end if;
               when others =>
                  nxR.state <= Init;   --ERROR
            end case;
         when others =>
            nxR.state <= Init;
      end case;

      case reg.ram.state is
         when Idle =>
            nxR.ram.wState <= Idle;
         when WaitShock =>
            case reg.ram.wState is
               when Idle =>
                  if reg.newData = cActivated then
                     nxR.ram.ctrl.write <= cActivated;
                     nxR.ram.wState     <= IncAddr;
                  end if;
               when IncAddr =>
                  nxR.ram.ctrl.wAddr <= reg.ram.ctrl.wAddr + 1;
                  nxR.ram.wState     <= Idle;

                  if (abs(signed(reg.shadowReg.data(3))) > signed(reg.shockLevel)) OR
                     (abs(signed(reg.shadowReg.data(4))) > signed(reg.shockLevel)) OR
                     (abs(signed(reg.shadowReg.data(5))) > signed(reg.shockLevel)) then

                     nxR.ram.state      <= RecShock;
                     nxR.ram.ctrl.rAddr <= reg.ram.ctrl.wAddr - gPreShockCount;
                  end if;
               when others =>
                  nxR.ram.state <= Idle;
            end case;
         when RecShock =>
            case reg.ram.wState is
               when Idle =>
                  if reg.ram.ctrl.wAddr = reg.ram.ctrl.rAddr then
                     nxR.ram.state  <= Idle;
                     nxR.ram.int    <= cActivated;
                     nxR.ram.avail  <= cActivated;
                  elsif reg.newData = cActivated then
                     nxR.ram.ctrl.write <= cActivated;
                     nxR.ram.wState     <= IncAddr;
                     nxR.ram.rState     <= AccX;
                  end if;
               when IncAddr =>
                  nxR.ram.ctrl.wAddr <= reg.ram.ctrl.wAddr + 1;
                  nxR.ram.wState     <= Idle;
               when others =>
                  nxR.ram.state <= Idle;
            end case;
         when others =>
            nxR.ram.state <= Idle;
      end case;

      -- Bus logic - read
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

            when cAddrCtrlAvail =>
               nxR.readdata(0) <= RamStateToULogic(reg.ram.state);
               nxR.readdata(1) <= reg.ram.avail;

            when cAddrIntEn =>
               nxR.readdata(0) <= reg.ram.intEn;

            when cAddrIntStatReg =>
               nxR.readdata(0) <= reg.ram.int;

            when cAddrShockLvl =>
               nxR.readdata(15 downto 0) <= reg.shockLevel;

            when cAddrBufData =>
               if reg.ram.avail = cActivated AND reg.ram.rInc = cActivated then
                  nxR.ram.rInc <= cInactivated;
                  case reg.ram.rState is
                     when AccX =>
                        nxR.readdata(aSensorValue'range) <= std_ulogic_vector(ramRData( 15 downto   0));
                        nxR.ram.rState <= AccY;
                     when AccY =>
                        nxR.readdata(aSensorValue'range) <= std_ulogic_vector(ramRData( 31 downto  16));
                        nxR.ram.rState <= AccZ;
                     when AccZ =>
                        nxR.readdata(aSensorValue'range) <= std_ulogic_vector(ramRData( 47 downto  32));
                        nxR.ram.rState <= GyroX;
                     when GyroX =>
                        nxR.readdata(aSensorValue'range) <= std_ulogic_vector(ramRData( 79 downto  64));
                        nxR.ram.rState <= GyroY;
                     when GyroY =>
                        nxR.readdata(aSensorValue'range) <= std_ulogic_vector(ramRData( 95 downto  80));
                        nxR.ram.rState <= GyroZ;
                     when GyroZ =>
                        nxR.readdata(aSensorValue'range) <= std_ulogic_vector(ramRData(111 downto  96));
                        nxR.ram.rState <= MagX;
                     when MagX =>
                        nxR.readdata(aSensorValue'range) <= std_ulogic_vector(ramRData(143 downto 128));
                        nxR.ram.rState <= MagY;
                     when MagY =>
                        nxR.readdata(aSensorValue'range) <= std_ulogic_vector(ramRData(159 downto 144));
                        nxR.ram.rState <= MagZ;
                     when MagZ =>
                        nxR.readdata(aSensorValue'range) <= std_ulogic_vector(ramRData(175 downto 160));
                        nxR.ram.rState <= TimeL;
                     when TimeL =>
                        nxR.readdata <= std_ulogic_vector(ramRData(223 downto 192));
                        nxR.ram.rState <= TimeH;
                     when TimeH =>
                        nxR.readdata <= std_ulogic_vector(ramRData(255 downto 224));
                        nxR.ram.rState <= AccX;
                        vRAddr := reg.ram.ctrl.rAddr + 1;
                        if vRAddr = reg.ram.ctrl.wAddr then
                           nxR.ram.avail <= cInactivated;
                        else
                           nxR.ram.ctrl.rAddr <= vRAddr;
                        end if;  
                     when others =>
                        null;
                  end case;
               else
                  nxR.readdata <= X"DEADBEEF";  -- Invalid read
               end if;

            when others =>
               nxR.readdata <= X"DEADCE11";  -- Invalid read
         end case ;
      end if;

      -- Bus logic - write
      if avs_s0_write = cActivated then
         case avs_s0_address is
            when cAddrCtrlAvail =>
               if avs_s0_writedata(0) = cActivated then
                  nxR.ram.state <= WaitShock;
               end if;
            when cAddrIntEn =>
               nxR.ram.intEn <= std_ulogic(avs_s0_writedata(0));
            when cAddrIntStatReg =>
               if avs_s0_writedata(0) = cActivated then
                  nxR.ram.int   <= cInactivated;
               end if;
            when cAddrShockLvl =>
               nxR.shockLevel <= std_ulogic_vector(avs_s0_writedata(15 downto 0));
         
            when others =>
               null;
         end case;
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

   ramWData(255 downto 192) <= std_ulogic_vector(reg.shadowReg.timestamp);
   ramWData(191 downto 176) <= X"DEA2";
   ramWData(175 downto 160) <= reg.shadowReg.data(8); -- Mag Z
   ramWData(159 downto 144) <= reg.shadowReg.data(7); -- Mag Y
   ramWData(143 downto 128) <= reg.shadowReg.data(6); -- Mag X
   ramWData(127 downto 112) <= X"DEA1";
   ramWData(111 downto  96) <= reg.shadowReg.data(2); -- Gyro Z
   ramWData( 95 downto  80) <= reg.shadowReg.data(1); -- Gyro Y
   ramWData( 79 downto  64) <= reg.shadowReg.data(0); -- Gyro X
   ramWData( 63 downto  48) <= X"DEA0";
   ramWData( 47 downto  32) <= reg.shadowReg.data(5); -- Acc Z
   ramWData( 31 downto  16) <= reg.shadowReg.data(4); -- Acc Y
   ramWData( 15 downto   0) <= reg.shadowReg.data(3); -- Acc X

   irq_irq <= reg.ram.intEn AND reg.ram.int;
   avs_s0_readdata <= std_logic_vector(reg.readdata);

end architecture rtl; -- of new_component
