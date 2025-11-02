--------------------------------------------------------------------------------
-- csa_tree
--
-- This module uses carry save adders to add multiple k-bit numbers at once.
-- The design combines the use of carry save adders to reduce the number of
-- inputs down to 2. Then these 2 inputs are inserted into a k-bit ripple
-- carry adder.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.general_package.all;
-------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------
entity csa_tree is
  generic (
    NUM_OF_INPUTS : positive := 3;
    SIZE_OF_INPUTS : positive := 4);
  port (
    inputs : in  slv_vector(0 to NUM_OF_INPUTS-1)(SIZE_OF_INPUTS-1 downto 0);
    outputs : out  slv_vector(0 to (2*NUM_OF_INPUTS/3)-1)(SIZE_OF_INPUTS-1 downto 0);
    sum    : out std_logic_vector(SIZE_OF_INPUTS+clog2(NUM_OF_INPUTS)-1 downto 0));
end csa_tree;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture rtl of csa_tree is
  CONSTANT HEIGHT : natural := csa_tree_height(NUM_OF_INPUTS);
  signal result : slv_vector(0 to NUM_OF_INPUTS-1)(SIZE_OF_INPUTS-1 downto 0);
begin
  --------------------------------------------------------------------------------
  -- csa generator
  --------------------------------------------------------------------------------
  csa_generate: for i in 0 to NUM_OF_INPUTS/3-1 generate
    csa1: entity work.carry_save_adder 
      generic map (
        N   => SIZE_OF_INPUTS)
      port map (
        x    => inputs(i*3),
        y    => inputs(i*3+1),
        cin  => inputs(i*3+2),
        sum  => outputs(i),
        cout => outputs(i+1));
  end generate csa_generate;
  sum <= (others => '0');
end rtl;
