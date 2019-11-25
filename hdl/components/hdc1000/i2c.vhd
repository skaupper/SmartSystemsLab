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

-- 0 -> TX Fifo (Write only)
--      31:10 Reserved
--       9:9  Repeated Start
--       8:8  Read/not Write
--       7:0  Data
-- 1 -> RX Fifo (Read only)
--      31:9  Reserved
--       8:8  Acknowledged
--       7:0  Data
-- 2 -> Control Register
--      31:1  -- Reserved
--       1:1  -W Write 1 Clear Fifo, Stop Transmission
--       0:0  RW Enable
-- 3 -> Status Register (Read only)
--      31:24 Tx Fifo Count
--      23:16 Rx Fifo Count
--      15:4  Reserved
--       3:3  Tx Fifo Full
--       2:2  Rx Fifo Empty
--       1:0  Status
--            "00": Idle
--            "01": Transmission
--            "10": Waiting on next command
--            "11": Error
--

entity i2c is
   generic (
      gClkFrequency    : natural := 100E6;  -- 100 MHz
      gI2cFrequency    : natural := 100E3); -- 100 kHz
   port (
      iClk             : in    std_logic                     := '0'               -- clock.clk 
      inRst            : in    std_logic                     := '0'               -- reset.reset 
      sda, scl         : inout std_logic;                    := 'Z'               -- I2C lines
      avs_s0_address   : in    std_logic_vector( 1 downto 0) := (others => '0');  -- avs_s0.address
      avs_s0_read      : in    std_logic                     := '0';              --       .read
      avs_s0_readdata  : out   std_logic_vector(31 downto 0);                     --       .readdata
      avs_s0_write     : in    std_logic                     := '0';              --       .write
      avs_s0_writedata : in    std_logic_vector(31 downto 0) := (others => '0')); --       .writedata
end entity i2c;

architecture rtl of i2c is

   component txfifo
      PORT
      (
         aclr  : in  std_logic;
         clock : in  std_logic;
         data  : in  std_logic_vector (9 downto 0);
         rdreq : in  std_logic;
         sclr  : in  std_logic;
         wrreq : in  std_logic;
         empty : out std_logic;
         full  : out std_logic;
         q     : out std_logic_vector (9 downto 0);
         usedw : out std_logic_vector (2 downto 0)
      );
   end component;

   component rxfifo
      PORT
      (
         aclr  : in  std_logic;
         clock : in  std_logic;
         data  : in  std_logic_vector (8 downto 0);
         rdreq : in  std_logic;
         sclr  : in  std_logic;
         wrreq : in  std_logic;
         empty : out std_logic;
         full  : out std_logic;
         q     : out std_logic_vector (8 downto 0);
         usedw : out std_logic_vector (2 downto 0)
      );
   end component;

   constant cTxFifoAddr : std_logic_vector(1 downto 0) := "00";
   constant cRxFifoAddr : std_logic_vector(1 downto 0) := "01";
   constant cCtrlAddr   : std_logic_vector(1 downto 0) := "10";
   constant cStatusAddr : std_logic_vector(1 downto 0) := "11";

   constant cI2cIdle    : std_logic_vector(1 downto 0) := "00";
   constant cI2cTrans   : std_logic_vector(1 downto 0) := "00";
   constant cI2cWaiting : std_logic_vector(1 downto 0) := "00";
   constant cI2cError   : std_logic_vector(1 downto 0) := "00";

   function toOpenDrain(X : std_ulogic)
      return std_ulogic is
   begin
      if X = "0" then
         return "0";
      else
         return "Z";
      end if;
   end function;

   function fromOpenDrain(X : std_ulogic)
      return std_ulogic is
   begin
      if X = "0" then
         return "0";
      else
         return "1";
      end if;
   end function;

   type aTxFifoIO is record
      clear : std_logic;
      write : std_logic;
      wData : std_logic_vector(9 downto 0);
      read  : std_logic;
      rData : std_logic_vector(9 downto 0);
      empty : std_logic;
      full  : std_logic;
      count : std_logic_vector(2 downto 0);
   end record;

   type aRxFifoIO is record
      clear : std_logic;
      write : std_logic;
      wData : std_logic_vector(8 downto 0);
      read  : std_logic;
      rData : std_logic_vector(8 downto 0);
      empty : std_logic;
      full  : std_logic;
      count : std_logic_vector(2 downto 0);
   end record;

   type aI2cState is (Idle, Start, Data, Ack, Waiting, Error);

   type aI2cFrame is record
      repeatedStart : std_ulogic;
      readNotWrite  : std_ulogic;
      ack           : std_ulogic;
      data          : std_ulogic_vector;
   end record;

   subtype aPhase is unsigned (1 downto 0);
   subtype aIndex is unsigned (2 downto 0);

   type aI2cRegSet is record
      state : aI2cState;
      frame : aI2cFrame;
      phase : aPhase;
      index : aIndex;
      sda   : std_ulogic;
      scl   : std_ulogic;
   end record;

   type aReadSource is (Reg, RxFifo)

   type aBusRegSet is record
      rData   : std_ulogic_vector(31 downto 0);
      rSource : std_ulogic;
   end record;

   type aRegSet is record
      bus : aBusRegSet;
      i2c : aI2cRegSet;
   end record;

   signal strobe   : std_ulogic;

   signal reg, nxR : aRegSet;
   signal txFifoIO : aTxFifoIO;
   signal rxFifoIO : aRxFifoIO;
begin

   strobe : entity work.StrobeGen
   generic map (
      gClkFrequency    => gClkFrequency,
      gStrobeFrequency => gI2cFrequency/4)
   port map (
      iClk             => iClk,
      inResetAsync     => inReset,
      oStrobe          => strobe);

   txfifo_inst : txfifo port map (
      aclr  => not inReset,
      clock => iClk,
      data  => txfifo.wData,
      rdreq => txfifo.read,
      sclr  => txfifo.clear,
      wrreq => txfifo.write,
      empty => txfifo.empty,
      full  => txfifo.full,
      q     => txfifo.rData,
      usedw => txfifo.count
   );

   rxfifo_inst : rxfifo port map (
      aclr  => not inReset,
      clock => iClk,
      data  => rxfifo.wData,
      rdreq => rxfifo.read,
      sclr  => rxfifo.clear,
      wrreq => rxfifo.write,
      empty => rxfifo.empty,
      full  => rxfifo.full,
      q     => rxfifo.rData,
      usedw => rxfifo.count
   );


   fsm : process( reg, avs_s0_read, msTick, avs_s0_address )
   begin
      nxR <= reg;
      nxR.clear <= cInactivated;
      nxR.bus.rData   <= X"BADC0DED"; -- just to spot mistakes
      nxR.bus.rSource <= Reg;

      txFifoIO.read   <= cInactivated;
      txFifoIO.write  <= cInactivated;
      
      rxFifoIO.read   <= cInactivated;
      rxFifoIO.write  <= cInactivated;
      rxFifoIO.wData  <= (others => "0");

      if avs_s0_read = cActivated then
         case avs_s0_address is
            when cRxFifoAddr =>
               if NOT rxFifoIO.empty then
                  nxR.bus.rSource <= RxFifo;
                  rxFifoIO.read <= cActivated;
               end if;
            when cCtrlAddr =>
               nxR.bus.rData(0) <= reg.enable;
            when cStatusAddr =>
               nxR.bus.rData <= (
                  26 downto 24 => txFifoIO.count,
                  18 downto 16 => rxFifoIO.count,
                  others => "0"
               );
               if reg.i2c.state = Idle then
                  nxR.bus.rData(1 downto 0) <= cI2cIdle;
               elsif reg.i2c.state = Waiting then
                  nxR.bus.rData(1 downto 0) <= cI2cWaiting;
               elsif reg.i2c.state = Error then
                  nxR.bus.rData(1 downto 0) <= cI2cError;
               else
                  nxR.bus.rData(1 downto 0) <= cI2cTrans;
               end if;
            when others =>
               null;
         end case ;
      end if;

      if avs_s0_write = cActivated then
         case avs_s0_address is
            when cTxFifoAddr =>
               if NOT txFifoIO.full then
                  txFifoIO.write <= cActivated;
               end if;
            when cCtrlAddr =>
               nxR.enable <= avs_s0_writedata(0);
               nxR.clear  <= avs_s0_writedata(1);
            when others =>
               null;
         end case ;
      end if;

      case reg.i2c.state is
         when Idle =>
            nxR.i2c.sda <= "Z";
            nxR.i2c.scl <= "Z";

            if NOT txFifoIO.empty then
               nxR.i2c.state <= Load;
               txFifoIO.read <= cActivated;
            end if;
         when Load =>
            nxR.i2c.state <= Start;
            nxR.i2c.phase <=  0;
            nxR.i2c.index <=  0;
            nxR.i2c.sda   <= "0";

            nxR.i2c.frame.repeatedStart <= txFifoIO.rData(9);
            nxR.i2c.frame.readNotWrite  <= txFifoIO.rData(8);
            nxR.i2c.frame.data          <= txFifoIO.rData(7 downto 0);
            nxR.i2c.frame.ack           <= "0";

         when Start =>
            if strobe = cActivated then
               nxR.i2c.phase <= R.i2c.phase + 1;
            end if;

            case( Reg.phase ) is
               when 0 =>
                  nxR.i2c.sda <= "0";
               when 1 =>
                  nxR.i2c.scl <= "0";
                  if strobe = cActivated then
                     nxR.i2c.state <= Data;
                     nxR.i2c.phase <= 0;
                  end if;
               when others =>
                  nxR.i2c.state <= Error;
            end case ;
         when Data =>
            if strobe = cActivated then
               nxR.i2c.phase <= R.i2c.phase + 1;
            end if;

            case reg.i2c.phase is
               when 0 =>
                  if readNotWrite then
                     nxR.i2c.sda <= 'Z';
                  else
                     nxR.i2c.sda <= R.i2c.data(R.idx);
                  end if;
               when 1 =>
                  nxR.i2c.scl <= "Z";
               when 2 =>
                  if readNotWrite then
                     nxR.i2c.data(R.i2c.idx) <= fromOpenDrain(sda);
                  end if;
               when 3 =>
                  nxR.i2c.scl   <= "0";

                  if strobe = cActivated then
                     nxR.i2c.phase <=  0;

                     if R.i2c.idx = 7 then
                        nxR.i2c.state <= Ack;
                     else
                        nxR.i2c.idx <= R.i2c.idx + 1;
                     end if;
                  end if;
               when others =>
                  nxR.i2c.state <= Error;
            end case;
         when Ack =>
            if strobe = cActivated then
               nxR.i2c.phase <= R.i2c.phase + 1;
            end if;

            case reg.i2c.phase is
               when 0 =>
                  if readNotWrite then
                     nxR.i2c.sda <= "0";
                  else
                     nxR.i2c.sda <= "Z";
                  end if;
               when 1 =>
                  nxR.i2c.scl <= "1";
               when 2 =>
                  nxR.i2c.ack <= fromOpenDrain(sda);
               when 3 =>
                  nxR.i2c.scl   <= "0";

                  if strobe = cActivated then
                     nxR.i2c.phase <=  0;
                     nxR.i2c.state <= Idle;   --TODO:
                  end if;
               when others =>
                  nxR.i2c.state <= Error;
            end case ;
         when Waiting =>
            -- TODO:
         when Error =>
            null;
         when others =>
            nxR.state <= Error;
      end case;
   end process; -- fsm

   regProc : process( iClk, inRst )
   begin
      if inRst = '0' then
         reg <= cRegSetClear;
      elsif (rising_edge(iClk)) then
         reg <= nxR;
      end if;
   end process ; -- regProc

   avs_s0_readdata <= std_logic_vector(reg.readdata)
                      when rSource = Reg
                      else rxFifoIO.rData;
   txFifoIOwData   <= avs_s0_writedata;

   sda <= toOpenDrain(reg.sda);
   scl <= toOpenDrain(reg.scl);

end architecture rtl; -- of new_component
