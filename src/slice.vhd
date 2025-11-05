--------------------------------------------------------------------------------
-- slice
--
-- takes a 2d slice of a 2d vector
-- takes LENGTH and DEPTH as generics to create a LENGTH x DEPTH 2d vector.
-- 2d input dimensions must be smaller than the output dimensions
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.general_package.all;

-------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------
entity slice is
  generic (
    INPUT_DEPTH  : natural := 3;
    INPUT_LENGTH : natural := 4;
    OUTPUT_MIN_DEPTH  : natural := 0;
    OUTPUT_MAX_DEPTH  : natural := 2;
    OUTPUT_MIN_LENGTH : natural := 0;
    OUTPUT_MAX_LENGTH : natural := 2);
  port (
    input2d  : in  slv_vector(0 to INPUT_DEPTH-1)(INPUT_LENGTH-1 downto 0);
    output2d : out slv_vector(0 to OUTPUT_MAX_DEPTH-OUTPUT_MIN_DEPTH-1)(OUTPUT_MAX_LENGTH-OUTPUT_MIN_LENGTH-1 downto 0));
end slice;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture rtl of slice is
  -------------------------------------------------------------------------------- 
  -- constants
  -------------------------------------------------------------------------------- 

  -------------------------------------------------------------------------------- 
  -- signals
  -------------------------------------------------------------------------------- 
begin
  --------------------------------------------------------------------------------
  -- initialize results vector
  --------------------------------------------------------------------------------
  process(input2d, output2d)
  begin
    for i in OUTPUT_MIN_DEPTH to OUTPUT_MAX_DEPTH-1 loop
      for j in OUTPUT_MIN_LENGTH to OUTPUT_MAX_LENGTH-1 loop
        output2d(i-OUTPUT_MIN_DEPTH)(j-OUTPUT_MIN_LENGTH) <= input2d(i)(j);
      end loop;
    end loop;
  end process;
end architecture rtl;
