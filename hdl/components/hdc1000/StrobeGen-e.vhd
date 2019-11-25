--------------------------------------------------------------------------------
-- Title       : Strobe generator
-- Project     : FPGA Based Digital Signal Processing
--               FH OÖ Hagenberg/HSD, SCD5
--------------------------------------------------------------------------------
-- RevCtrl     : $Id: StrobeGen-e.vhd 664 2017-09-26 19:39:57Z mroland $
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
