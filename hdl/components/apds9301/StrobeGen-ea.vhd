--------------------------------------------------------------------------------
-- Title       : Strobe generator
-- Project     : FPGA Based Digital Signal Processing
--               FH OÖ Hagenberg/HSD, SCD5
--------------------------------------------------------------------------------
-- RevCtrl     : $Id: StrobeGen-Rtl-a.vhd 664 2017-09-26 19:39:57Z mroland $
-- Authors     : Markus Pfaff, Linz/Austria, Copyright (c) 2003-2005
--               Michael Roland, Hagenberg/Austria, Copyright (c) 2011-2017
--------------------------------------------------------------------------------
-- Description : Generates a strobe signal that will be '1' for one cycle of
--               iClk. The strobe comes every gStrobeCycleTime. If this cycle
--               time cannot be generated exactly, it will be truncated to
--               the accuracy of one iClk cycle.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Global.all;

entity StrobeGen is
  
  generic (
    gClkFrequency    : natural := 48E6;
    gStrobeFrequency : natural := 12E6);  -- 12 MHz

  port (
    -- Sequential logic inside this unit
    iClk         : in std_ulogic;
    inResetAsync : in std_ulogic;

    -- Strobe with the above given cycle time
    oStrobe : out std_ulogic);
  
-- pragma translate_off
begin

  assert (gClkFrequency >= gStrobeFrequency)
    report "Mp: The Clk frequency is to low to generate such a short strobe cycle."
    severity error;
-- pragma translate_on
  
end StrobeGen;

architecture Rtl of StrobeGen is

  -- How many iClk cycles make up one strobe cycle?
  -- Not as easy as it looks at first glance! The result will tend to be to small,
  -- because we only integer divide here. A remainder other than 0 will typically result.
  -- Example:
  -- Generate a 6 MHz strobe from a 48 MHz iClk.
  -- 48E6/6E6=8, but consider the very similar equation 48E6/(6E6+1)=7!
  -- Example:
  -- Generate the strobe that comes closest to 44100 kHz (audio CD sampling rate) from
  -- a 48 MHz iClk.
  -- 48E6/44110=1088, (keep in mind that 48E6/44118 would be 1087 already).
  -- The choosen value (i.e. 1088) will lead to a slightly higher frequency
  -- of 44117.65 Hz.
  constant cClkCycPerStrobeCyc : natural :=
    gClkFrequency / gStrobeFrequency;
  -- How many binary digits are needed to keep track of a counter that can count from 0
  -- to the number of iClk cycles -1 needed for one strobe cycle?
  constant cClkCounterBinDigitCount : natural :=
    LogDualis(cClkCycPerStrobeCyc);

  -- The register whe use for counting the iClk cycles.
  signal ClkCounter : unsigned(cClkCounterBinDigitCount-1 downto 0);

begin  -- architecture Rtl

  -- Count the number of Clk cycles from strobe pulse to strobe pulse.
  GenStrobe : process (iClk, inResetAsync) is
  begin  -- process GenStrobe

    -- Asynchronous reset
    if (inResetAsync = cResetActive) then

      -- We begin counting at 0.
      ClkCounter <= to_unsigned(0, ClkCounter'length);
      -- oStrobe shall be sourced directly by a register output to ease time budgeting
      -- when several units are connected with each other.
      oStrobe <= cInactivated;

    -- Rising clk edge
    elsif rising_edge(iClk) then

      -- We count from 0 to cClkCycPerStrobeCyc-1.
      if ClkCounter = cClkCycPerStrobeCyc-1 then
        ClkCounter <= (others => '0');
        -- The condition that sent us here will hold for exactly one iClk cycle. This
        -- will be the cycle during which the sStrobe signal is active. It's inactive
        -- during all other iClk cycles.
        oStrobe    <= cActivated;
      else
        ClkCounter <= ClkCounter+1;
        oStrobe    <= cInactivated;
      end if;

    end if;
  end process GenStrobe;

end architecture Rtl;
