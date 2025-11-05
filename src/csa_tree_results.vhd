--------------------------------------------------------------------------------
-- csa_tree_results_results
--
-- Given a 2d vector of sums and a 2d vector of carry outs, determine the output
-- as a 2d vector of results that imitate the results of a single level of a 
-- csa tree result. It should act like below for the first level of 4 inputs:
      --results(i+1)(0)(SIZE_OF_INPUTS-1 downto 0) <= sums(i)(0);
      --results(i+1)(1)(SIZE_OF_INPUTS-1 downto 0) <= sums(i)(1);
      --results(i+1)(2)(SIZE_OF_INPUTS   downto 0) <= carry_outs(i)(0) & '0';
      --results(i+1)(3)(SIZE_OF_INPUTS-1 downto 0) <= (SIZE_OF_INPUTS-1 downto 0 => '0');
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.general_package.all;

-------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------
entity csa_tree_results is
  generic (
    SIZE_OF_RESULT : natural := 4;
    SIZE_OF_INPUTS : natural := 4;
    NUM_OF_SUMS    : natural := 2;
    NUM_OF_COUTS   : natural := 1);
  port map(
    sums           : slv_vector(0 to NUM_OF_SUMS-1)(SIZE_OF_INPUTS-1 downto 0);
    carry_outs     : slv_vector(0 to NUM_OF_COUTS-1)(SIZE_OF_INPUTS-1 downto 0);
    results        : slv_vector(0 to ));
end csa_tree_results;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture rtl of csa_tree_results is
  -------------------------------------------------------------------------------- 
  -- constants
  -------------------------------------------------------------------------------- 
  CONSTANT HEIGHT   : natural := csa_tree_results_height(NUM_OF_INPUTS);

  -------------------------------------------------------------------------------- 
  -- signals
  -------------------------------------------------------------------------------- 
  signal results    : slvv_vector(0 to HEIGHT  )(0 to NUM_OF_INPUTS                           - 1)(SIZE_OF_INPUTS+flog2(NUM_OF_INPUTS)-1 downto 0) := (others => (others => (others => '0')));
  signal csa_inputs : slvv_vector(0 to HEIGHT-1)(0 to NUM_OF_INPUTS                           - 1)(SIZE_OF_INPUTS-1 downto 0);
  signal carry_outs : slvv_vector(0 to HEIGHT-1)(0 to NUM_OF_INPUTS/3                         - 1)(SIZE_OF_INPUTS-1 downto 0);
  signal sums       : slvv_vector(0 to HEIGHT-1)(0 to NUM_OF_INPUTS/3 + (NUM_OF_INPUTS mod 3) - 1)(SIZE_OF_INPUTS-1 downto 0); 
begin
  --------------------------------------------------------------------------------
  -- initialize results vector
  --------------------------------------------------------------------------------
  populate_results: process(results, inputs)
  begin
    for i in 0 to NUM_OF_INPUTS-1 loop
      if 
    end loop;
  end process;


  --------------------------------------------------------------------------------
  -- csa generator
  --------------------------------------------------------------------------------
  csa_reduce_generate: for i in 0 to HEIGHT-1 generate
    slice1: entity work.slice
      generic map(
        INPUT_DEPTH       => results(i)'length,
        INPUT_LENGTH      => results(i)(0)'length,
        OUTPUT_MIN_DEPTH  => 0,
        OUTPUT_MAX_DEPTH  => csa_inputs(i)'length,
        OUTPUT_MIN_LENGTH => 0,
        OUTPUT_MAX_LENGTH => csa_inputs(i)(0)'length)
      port map(
        input2d => results(i),
        output2d => csa_inputs(i));

    csa1: entity work.csa_tree_results_level 
      generic map (
        NUM_OF_INPUTS  => NUM_OF_INPUTS, -- may have to change num_of_inputs at each iteration
        SIZE_OF_INPUTS => SIZE_OF_INPUTS)
      port map (
        inputs         => csa_inputs(i),
        carry_outs     => carry_outs(i),
        sums           => sums(i));
    
        generic map(
          SIZE_OF_RESULT => results(i+1)'length,
          SIZE_OF_INPUTS => SIZE_OF_INPUTS,
          NUM_OF_SUMS    => sums(i)'length,
          NUM_OF_COUTS   => carry_outs(i)'length)
        port map(
          sums           => sums(i),
          carry_outs     => carry_outs(i),
          results        => results(i+1));

      --results(i+1)(0)(SIZE_OF_INPUTS-1 downto 0) <= sums(i)(0);
      --results(i+1)(1)(SIZE_OF_INPUTS-1 downto 0) <= sums(i)(1);
      --results(i+1)(2)(SIZE_OF_INPUTS   downto 0) <= carry_outs(i)(0) & '0';
      --results(i+1)(3)(SIZE_OF_INPUTS-1 downto 0) <= (SIZE_OF_INPUTS-1 downto 0 => '0');
    end generate result_populate_gen;
  end generate csa_reduce_generate;
  
  fa1: entity work.n_bit_full_adder -- find a way to add the results here. Might be able to use the last index of the 3d carry_outs and sums
    generic map(
      SIZE => SIZE_OF_INPUTS)
    port map(
      x    => carry_outs(0)(0),
      y    => sums(0)(0) srl 1,
      cin  => '0',
      cout => cout,
      sum  => sum(sum'length-1 downto sum'length-SIZE_OF_INPUTS));
    sum(0) <= sums(1)(0)(0);
end architecture rtl;
