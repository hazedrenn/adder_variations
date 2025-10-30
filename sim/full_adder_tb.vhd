-------------------------------------------------------------------------------
-- full_adder_tb
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

library work;
use work.sim_io_package.all;

-------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------
entity full_adder_tb is
end entity full_adder_tb;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture behavior of full_adder_tb is
  -------------------------------------------------------------------------------
  -- constants
  -------------------------------------------------------------------------------
  constant PERIOD: time := 1 ns;

  -------------------------------------------------------------------------------
  -- signals
  -------------------------------------------------------------------------------
  signal signal_x   : std_logic;
  signal signal_y   : std_logic;
  signal signal_cin : std_logic;
  signal signal_cout: std_logic;
  signal signal_sum : std_logic;
begin
  -------------------------------------------------------------------------------
  -- dut
  -------------------------------------------------------------------------------
  dut: entity work.full_adder
  port map (
    x => signal_x,
    y => signal_y,
    cin => signal_cin,
    cout => signal_cout,
    sum => signal_sum);

  -------------------------------------------------------------------------------
  -- stimulus
  -------------------------------------------------------------------------------
  stimulus: process
    variable expected_sum : std_logic;
    variable expected_cout: std_logic;
  begin
    print("** Testing full_adder");

    wait for PERIOD;

    -- Validate all input combinations
    for x in std_logic range '0' to '1' loop
      for y in std_logic range '0' to '1' loop
        for cin in std_logic range '0' to '1' loop
          signal_x   <= x; 
          signal_y   <= y; 
          signal_cin <= cin;

          -- Calculate Expected Sum and Carry Out Values
          expected_sum := x xor y xor cin;
          expected_cout := (x and y) or (x and cin) or (y and cin);

          wait for PERIOD;

          -- Validate sum and cout
          assert expected_sum = signal_sum 
            report "Wrong sum value, expected" & std_logic'image(expected_sum) & ". Actual: " & std_logic'image(signal_sum) & ". "
            severity FAILURE;

          assert expected_cout = signal_cout 
            report "Wrong carry out value, expected" & std_logic'image(expected_cout) & ". Actual: " & std_logic'image(signal_cout) & ". "
            severity FAILURE;
        end loop;
      end loop;
    end loop;

    print("** full_adder test PASSED");
    wait for PERIOD;
    finish;
  end process;
end architecture behavior;
