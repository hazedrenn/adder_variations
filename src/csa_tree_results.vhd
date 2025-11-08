--------------------------------------------------------------------------------
-- csa_tree_results_results
--
-- Given a 2d vector of sums and a 2d vector of carry outs, determine the output
-- as a 2d vector of results that imitate the results of a single level of a 
-- csa tree result. It should act like below for the first level of 4 inputs:
--
-- results(i+1)(0)(SIZE_OF_INPUTS-1 downto 0) <= sums(i)(0);
-- results(i+1)(1)(SIZE_OF_INPUTS-1 downto 0) <= sums(i)(1);
-- results(i+1)(2)(SIZE_OF_INPUTS   downto 0) <= carry_outs(i)(0) & '0';
-- results(i+1)(3)(SIZE_OF_INPUTS-1 downto 0) <= (SIZE_OF_INPUTS-1 downto 0 => '0');
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
    SIZE_OF_RESULTS : natural := 6;
    NUM_OF_RESULTS  : natural := 4;
    SIZE_OF_INPUTS  : natural := 4;
    NUM_OF_SUMS     : natural := 2;
    NUM_OF_COUTS    : natural := 1);
  port (
    sums            : in  slv_vector(0 to NUM_OF_SUMS-1)(SIZE_OF_INPUTS-1 downto 0);
    carry           : in  slv_vector(0 to NUM_OF_COUTS-1)(SIZE_OF_INPUTS-1 downto 0);
    results_in      : in  slv_vector(0 to NUM_OF_RESULTS-1)(SIZE_OF_RESULTS-1 downto 0);
    results_out     : out slv_vector(0 to NUM_OF_RESULTS-1)(SIZE_OF_RESULTS-1 downto 0));
end csa_tree_results;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture rtl of csa_tree_results is
  -------------------------------------------------------------------------------- 
  -- constants
  -------------------------------------------------------------------------------- 
  -------------------------------------------------------------------------------- 
  -- signals
  --------------------------------------------------------------------------------
  --signal raw_results : slv_vector(0 to NUM_OF_RESULTS-1)(SIZE_OF_RESULTS-1 downto 0);
  --signal bit_count   : integer_2vector(0 to NUM_OF_RESULTS-1)(SIZE_OF_RESULTS-1 downto 0) := (others => (others => 0));
    signal bit_count_sig: integer_vector(SIZE_OF_RESULTS-1 downto 0) := (others => 0);
begin
  --------------------------------------------------------------------------------
  -- initialize results vector
  --------------------------------------------------------------------------------
  populate_results: process(results_in, results_out, sums, carry)
    --variable bit_count: integer_2vector(0 to NUM_OF_RESULTS-1)(SIZE_OF_RESULTS-1 downto 0) := (others => (others => 0));
    variable bit_count: integer_vector(SIZE_OF_RESULTS-1 downto 0) := (others => 0);
    variable r: slv_vector(0 to NUM_OF_RESULTS-1)(SIZE_OF_RESULTS-1 downto 0) := (others => (others => '0'));
  begin
    -- Fill result vector with sums
    for i in 0 to sums'length-1 loop
      for j in 0 to sums(i)'length-1 loop
        if sums(i)(j) = '1' then
          bit_count(j) := bit_count(j) + 1;
        end if;
      end loop;
    end loop;

    -- Fill result vector with carry
    for i in 0 to carry'length-1 loop
      for j in 0 to carry(i)'length-1 loop
        if carry(i)(j) = '1' then
          bit_count(j+1) := bit_count(j+1) + 1;
        end if;
      end loop;
    end loop;

    -- Fill result vector with results_in
    for i in 0 to results_in'length-1 loop
      for j in 0 to results_in(i)'length-1 loop
        if results_in(i)(j) = '1' then
          bit_count(j) := bit_count(j) + 1;
        end if;
      end loop;
    end loop;

    -- Using built-up bit counts, create a new results vector
    for i in 0 to r'length-1 loop
      for j in 0 to r(i)'length-1 loop
        if i < bit_count(j) then
          r(i)(j) := '1';
        end if;
      end loop;
    end loop;

    bit_count_sig <= bit_count;
    results_out <= r;
    bit_count := (others=> 0);
    r := (others => (others => '0'));
  end process;
end architecture rtl;
