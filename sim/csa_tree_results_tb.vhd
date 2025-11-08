-------------------------------------------------------------------------------
-- csa_tree_results_tb
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

library work;
use work.sim_io_package.all;
use work.general_package.all;

-------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------
entity csa_tree_results_tb is
  generic (
    SIZE_OF_RESULTS : natural := 6;
    NUM_OF_RESULTS  : natural := 4;
    SIZE_OF_INPUTS  : natural := 4;
    NUM_OF_SUMS     : natural := 2;
    NUM_OF_COUTS    : natural := 1);
end entity csa_tree_results_tb;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture behavior of csa_tree_results_tb is
  -------------------------------------------------------------------------------
  -- constants
  -------------------------------------------------------------------------------
  constant PERIOD: time := 1 ns;

  -------------------------------------------------------------------------------
  -- signals
  -------------------------------------------------------------------------------
  signal signal_sums       : slv_vector(0 to NUM_OF_SUMS-1)(SIZE_OF_INPUTS-1 downto 0);
  signal signal_carry_outs : slv_vector(0 to NUM_OF_COUTS-1)(SIZE_OF_INPUTS-1 downto 0);
  signal signal_results_in : slv_vector(0 to NUM_OF_RESULTS-1)(SIZE_OF_RESULTS-1 downto 0) := ("010000","010000","000000","000000");
  signal signal_results_out: slv_vector(0 to NUM_OF_RESULTS-1)(SIZE_OF_RESULTS-1 downto 0);
begin
  -------------------------------------------------------------------------------
  -- dut
  -------------------------------------------------------------------------------
  dut: entity work.csa_tree_results
    generic map (
      SIZE_OF_RESULTS => SIZE_OF_RESULTS,
      NUM_OF_RESULTS  => NUM_OF_RESULTS ,
      SIZE_OF_INPUTS  => SIZE_OF_INPUTS ,
      NUM_OF_SUMS     => NUM_OF_SUMS    ,
      NUM_OF_COUTS    => NUM_OF_COUTS   )
    port map (
      sums            => signal_sums,
      carry           => signal_carry_outs,
      results_in      => signal_results_in,
      results_out     => signal_results_out);

  -------------------------------------------------------------------------------
  -- stimulus
  -------------------------------------------------------------------------------
  stimulus: process
  begin
    print("** Testing csa_tree_results");

    for i in 0 to signal_sums'length-1 loop
      signal_sums(i) <= (others => '1');
    end loop;
    signal_sums(1) <= (others => '0');

    for i in 0 to signal_carry_outs'length-1 loop
      signal_carry_outs(i) <= (others => '1');
    end loop;

    wait for PERIOD;

    print("Sums:");
    for i in 0 to signal_sums'length-1 loop
      print(to_string(signal_sums(i)));
    end loop;

    print("Carry Outs:");
    for i in 0 to signal_carry_outs'length-1 loop
      print(to_string(signal_carry_outs(i)));
    end loop;

    print("---- csa_tree_results ----");
    
    for i in 0 to signal_results_out'length-1 loop
      print(to_string(signal_results_out(i)));
    end loop;

    print("** csa_tree_results test PASSED");
    wait for PERIOD;
    finish;
  end process;
end architecture behavior;
