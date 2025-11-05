-------------------------------------------------------------------------------
-- csa_tree_level_tb
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
entity csa_tree_level_tb is
  generic(
    NUM_OF_INPUTS  : positive :=  8;
    SIZE_OF_INPUTS : positive :=  4);
end entity csa_tree_level_tb;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture behavior of csa_tree_level_tb is
  -------------------------------------------------------------------------------
  -- constants
  -------------------------------------------------------------------------------
  constant PERIOD: time := 1 ns;

  -------------------------------------------------------------------------------
  -- signals
  -------------------------------------------------------------------------------
  signal signal_inputs     : slv_vector(0 to NUM_OF_INPUTS-1)(SIZE_OF_INPUTS-1 downto 0);
  signal signal_carry_outs : slv_vector(0 to NUM_OF_INPUTS/3 - 1)(SIZE_OF_INPUTS-1 downto 0);
  signal signal_sums       : slv_vector(0 to NUM_OF_INPUTS/3 + (NUM_OF_INPUTS mod 3) - 1)(SIZE_OF_INPUTS-1 downto 0);
begin
  -------------------------------------------------------------------------------
  -- dut
  -------------------------------------------------------------------------------
  dut: entity work.csa_tree_level
  generic map( 
    NUM_OF_INPUTS  => NUM_OF_INPUTS,
    SIZE_OF_INPUTS => SIZE_OF_INPUTS)
  port map (
    inputs         => signal_inputs, 
    carry_outs     => signal_carry_outs,  
    sums           => signal_sums); 

  -------------------------------------------------------------------------------
  -- stimulus
  -------------------------------------------------------------------------------
  stimulus: process
  begin
    print("** Testing csa_tree_level");
    signal_inputs(0) <= "1111";
    signal_inputs(1) <= "1111";
    signal_inputs(2) <= "1111";

    signal_inputs(3) <= "1111";
    signal_inputs(4) <= "1111";
    signal_inputs(5) <= "1111";

    signal_inputs(6) <= "1101";
    signal_inputs(7) <= "1010";
    wait for PERIOD;
    print("Height is "& integer'image(csa_tree_height(NUM_OF_INPUTS)));
    print("modulo is "& integer'image(NUM_OF_INPUTS mod 3));

    print(" "&to_string(signal_inputs(0)));
    print(" "&to_string(signal_inputs(1)));
    print(" "&to_string(signal_inputs(2)));
    print(" "&to_string(signal_inputs(3)));
    print(" "&to_string(signal_inputs(4)));
    print(" "&to_string(signal_inputs(5)));
    print(" "&to_string(signal_inputs(6)));
    print(" "&to_string(signal_inputs(7)));
    print(" ----");
    print(" "&to_string(signal_sums(0)));
    print(    to_string(signal_carry_outs(0)));
    print(" "&to_string(signal_sums(1)));
    print(    to_string(signal_carry_outs(1)));
    print(" "&to_string(signal_sums(2)));
    print(" "&to_string(signal_sums(3)));

    print("** csa_tree_level test PASSED");
    wait for PERIOD;
    finish;
  end process;
end architecture behavior;
