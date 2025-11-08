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
    NUM_OF_INPUTS  : positive := 3;
    SIZE_OF_INPUTS : positive := 4);
  port (
    inputs         : in  slv_vector(0 to NUM_OF_INPUTS-1)(SIZE_OF_INPUTS-1 downto 0);
    sum            : out std_logic_vector(SIZE_OF_INPUTS+flog2(NUM_OF_INPUTS)-1 downto 0));
end csa_tree;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture rtl of csa_tree is
  -------------------------------------------------------------------------------- 
  -- constants
  -------------------------------------------------------------------------------- 
  CONSTANT HEIGHT      : natural := csa_tree_height(NUM_OF_INPUTS);

  -------------------------------------------------------------------------------- 
  -- signals
  -------------------------------------------------------------------------------- 
  signal results      : slvv_vector( HEIGHT downto 0 )(0 to NUM_OF_INPUTS   - 1)(SIZE_OF_INPUTS+flog2(NUM_OF_INPUTS)-1 downto 0) := (others => (others => (others => '0')));
  signal result_couts : slvv_vector( HEIGHT downto 0 )(0 to NUM_OF_INPUTS   - 1)(SIZE_OF_INPUTS+flog2(NUM_OF_INPUTS)-1 downto 0) := (others => (others => (others => '0')));
  signal csa_inputs   : slvv_vector( HEIGHT downto 1 )(0 to NUM_OF_INPUTS   - 1)(SIZE_OF_INPUTS-1 downto 0);
  signal carry_outs   : slvv_vector( HEIGHT downto 1 )(0 to NUM_OF_INPUTS/3 - 1)(SIZE_OF_INPUTS-1 downto 0);
  signal sums         : slvv_vector( HEIGHT downto 1 )(0 to NUM_OF_INPUTS/3 + NUM_OF_INPUTS mod 3  - 1)(SIZE_OF_INPUTS-1 downto 0); 
  signal rca_in       : slv_vector( 0 to 1 )(SIZE_OF_INPUTS+flog2(NUM_OF_INPUTS)-1 downto 0);
  signal carries      : std_logic_vector( NUM_OF_INPUTS-1 downto 0);
  signal bit_count    : integer_2vector(HEIGHT downto 0)(0 to NUM_OF_INPUTS) := (others => (others => 0));
  signal cout         : std_logic;
begin
  --------------------------------------------------------------------------------
  -- initialize results vector
  --------------------------------------------------------------------------------
  populate_results: process(results, inputs)
  begin
    for i in 0 to NUM_OF_INPUTS-1 loop
      results(HEIGHT)(i)(SIZE_OF_INPUTS-1 downto 0) <= inputs(i);
    end loop;
  end process;


  --------------------------------------------------------------------------------
  -- csa generator
  --------------------------------------------------------------------------------
  csa_reduce_generate: for i in HEIGHT downto 1 generate
    -- Add inputs into CSA tree level
    csa_input_gen: for j in 0 to csa_inputs(i)'length-1 generate
      csa_inputs(i)(j)  <= results(i)(j)(csa_inputs(i)(j)'length-1 downto 0);
    end generate;

    csa1: entity work.csa_tree_level 
      generic map (
        NUM_OF_INPUTS   => NUM_OF_INPUTS, 
        SIZE_OF_INPUTS  => SIZE_OF_INPUTS)
      port map (
        inputs          => csa_inputs(i),
        carry_outs      => carry_outs(i),
        sums            => sums(i));
    
    -- Separate bits not used in reduction
    result_cout_gen: for j in 0 to results(i)'length-1 generate
      result_cout_j_gen: for k in sums(i)(j)'length to results(i)(j)'length-1 generate
        result_couts(i)(j)(k) <= results(i)(j)(k);
      end generate;
    end generate;
    
    -- Add all sums into results array for next level
    dut: entity work.csa_tree_results
      generic map (
        SIZE_OF_RESULTS => results(i)(0)'length,
        NUM_OF_RESULTS  => results(i)'length,
        SIZE_OF_INPUTS  => sums(i)(0)'length,
        NUM_OF_SUMS     => sums(i)'length,
        NUM_OF_COUTS    => carry_outs(i)'length)
      port map (
        sums            => sums(i),
        carry           => carry_outs(i),
        results_in      => result_couts(i),
        results_out     => results(i-1));
  end generate csa_reduce_generate;

  
  --------------------------------------------------------------------------------
  -- last stage Ripple Carry Adder
  --------------------------------------------------------------------------------
  rca_in_gen: for i in 0 to rca_in'length-1 generate
    rca_in(i) <= results(0)(i);
  end generate;

  fa1: entity work.n_bit_full_adder
    generic map (
      SIZE => SIZE_OF_INPUTS)
    port map (
      x    => rca_in(0)(rca_in(0)'length-1 downto rca_in(0)'length-SIZE_OF_INPUTS),
      y    => rca_in(1)(rca_in(1)'length-1 downto rca_in(0)'length-SIZE_OF_INPUTS),
      cin  => '0',
      cout => cout,
      sum  => sum(sum'length-1 downto sum'length-SIZE_OF_INPUTS));

  sum(sum'length-1) <= cout;
  sum(0) <= rca_in(0)(0);
end architecture rtl;
