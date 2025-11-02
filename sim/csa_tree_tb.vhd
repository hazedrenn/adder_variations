-------------------------------------------------------------------------------
-- csa_tree_tb
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
entity csa_tree_tb is
  generic(
    NUM_OF_INPUTS  : positive :=  3;
    SIZE_OF_INPUTS : positive :=  4 );
end entity csa_tree_tb;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture behavior of csa_tree_tb is
  -------------------------------------------------------------------------------
  -- constants
  -------------------------------------------------------------------------------
  constant PERIOD: time := 1 ns;

  -------------------------------------------------------------------------------
  -- signals
  -------------------------------------------------------------------------------
  signal signal_inputs : slv_vector(0 to NUM_OF_INPUTS-1)(SIZE_OF_INPUTS-1 downto 0);
  signal signal_outputs : slv_vector(0 to (2*NUM_OF_INPUTS/3)-1)(SIZE_OF_INPUTS-1 downto 0);
  signal signal_sum    : std_logic_vector(SIZE_OF_INPUTS+clog2(NUM_OF_INPUTS)-1 downto 0);
begin
  -------------------------------------------------------------------------------
  -- dut
  -------------------------------------------------------------------------------
  dut: entity work.csa_tree
  generic map( 
    NUM_OF_INPUTS  => NUM_OF_INPUTS,
    SIZE_OF_INPUTS => SIZE_OF_INPUTS)
  port map (
    inputs => signal_inputs,
    outputs => signal_outputs,
    sum    => signal_sum);

  -------------------------------------------------------------------------------
  -- stimulus
  -------------------------------------------------------------------------------
  stimulus: process
  begin
    print("** Testing csa_tree");
    signal_inputs(0) <= "1111";
    signal_inputs(1) <= "1111";
    signal_inputs(2) <= "1111";

    wait for PERIOD;
    print("Height is "& integer'image(csa_tree_height(NUM_OF_INPUTS)));

    print(" "&to_string(signal_inputs(0)));
    print(" "&to_string(signal_inputs(1)));
    print(" "&to_string(signal_inputs(2)));
    print(" ----");
    print(" "&to_string(signal_outputs(0)));
    print(to_string(signal_outputs(1)));

    print("** csa_tree test PASSED");
    wait for PERIOD;
    finish;
  end process;
end architecture behavior;
