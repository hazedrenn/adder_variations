-------------------------------------------------------------------------------
-- slice_tb
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
entity slice_tb is
  generic(
    INPUT_DEPTH  : natural := 3;
    INPUT_LENGTH : natural := 4;
    OUTPUT_MIN_DEPTH  : natural := 0;
    OUTPUT_MAX_DEPTH  : natural := 2;
    OUTPUT_MIN_LENGTH : natural := 0;
    OUTPUT_MAX_LENGTH : natural := 3);
end entity slice_tb;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture behavior of slice_tb is
  -------------------------------------------------------------------------------
  -- constants
  -------------------------------------------------------------------------------
  constant PERIOD: time := 1 ns;

  -------------------------------------------------------------------------------
  -- signals
  -------------------------------------------------------------------------------
  signal signal_input2d  : slv_vector(0 to INPUT_DEPTH-1)(INPUT_LENGTH-1 downto 0);
  signal signal_output2d : slv_vector(0 to OUTPUT_MAX_DEPTH-OUTPUT_MIN_DEPTH-1)(OUTPUT_MAX_LENGTH-OUTPUT_MIN_LENGTH-1 downto 0);
begin
  -------------------------------------------------------------------------------
  -- dut
  -------------------------------------------------------------------------------
  dut: entity work.slice
  generic map (
    INPUT_DEPTH   => INPUT_DEPTH   ,
    INPUT_LENGTH  => INPUT_LENGTH  ,
    OUTPUT_MIN_DEPTH  => OUTPUT_MIN_DEPTH  ,
    OUTPUT_MAX_DEPTH  => OUTPUT_MAX_DEPTH  ,
    OUTPUT_MIN_LENGTH => OUTPUT_MIN_LENGTH ,
    OUTPUT_MAX_LENGTH => OUTPUT_MAX_LENGTH )
  port map (
    input2d       => signal_input2d, 
    output2d      => signal_output2d);

  -------------------------------------------------------------------------------
  -- stimulus
  -------------------------------------------------------------------------------
  stimulus: process
  begin
    print("** Testing slice");
    for i in 0 to signal_input2d'length-1 loop
      signal_input2d(i) <= std_logic_vector(to_unsigned(i, signal_input2d(i)'length));
    end loop;

    wait for PERIOD;

    for i in 0 to signal_input2d'length-1 loop
      print(to_string(signal_input2d(i)));
    end loop;

    print("---- slice ----");
    
    for i in 0 to signal_output2d'length-1 loop
      print(to_string(signal_output2d(i)));
    end loop;

    print("** slice test PASSED");
    wait for PERIOD;
    finish;
  end process;
end architecture behavior;
