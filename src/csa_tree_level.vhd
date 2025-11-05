--------------------------------------------------------------------------------
-- csa_tree_level
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.general_package.all;

-------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------
entity csa_tree_level is
  generic (
    NUM_OF_INPUTS  : positive := 3;
    SIZE_OF_INPUTS : positive := 4);
  port (
    inputs     : in  slv_vector(0 to NUM_OF_INPUTS - 1)(SIZE_OF_INPUTS-1 downto 0);
    carry_outs : out slv_vector(0 to NUM_OF_INPUTS/3 - 1)(SIZE_OF_INPUTS-1 downto 0);
    sums       : out slv_vector(0 to NUM_OF_INPUTS/3 + (NUM_OF_INPUTS mod 3) - 1)(SIZE_OF_INPUTS-1 downto 0));
end csa_tree_level;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture rtl of csa_tree_level is
begin
  --------------------------------------------------------------------------------
  -- csa generator
  ---- Makes a 3 input to 2 output reduction using full adders.
  --------------------------------------------------------------------------------
  csa_reduce_generate: for i in 0 to NUM_OF_INPUTS/3-1 generate
    csa1: entity work.carry_save_adder 
      generic map (
        N    => SIZE_OF_INPUTS)
      port map (
        x    => inputs(i*3),
        y    => inputs(i*3+1),
        cin  => inputs(i*3+2),
        sum  => sums(i),
        cout => carry_outs(i));
  end generate csa_reduce_generate;

  -------------------------------------------------------------------------------- 
  -- Pass-In generators
  ---- If there are leftover inputs that cannot be reduced, store them into sums 
  ---- vector.
  -------------------------------------------------------------------------------- 
  pass_in_generate_0: if NUM_OF_INPUTS mod 3 = 1 generate
    sums(sums'length-1) <= inputs(inputs'length-1);
  end generate pass_in_generate_0;

  pass_in_generate_1: if NUM_OF_INPUTS mod 3 = 2 generate
    sums(sums'length-2) <= inputs(inputs'length-2);
    sums(sums'length-1) <= inputs(inputs'length-1);
  end generate pass_in_generate_1;
end architecture rtl;
