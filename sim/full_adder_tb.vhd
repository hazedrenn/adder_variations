library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

library work;
use work.my_package.all;

entity full_adder_tb is
end entity full_adder_tb;

architecture behavior of full_adder_tb is
  component full_adder is
  port (
    x: in std_logic;
    y: in std_logic;
    cin: in std_logic;
    cout: out std_logic;
    sum: out std_logic);
  end component full_adder;

  signal signal_x: std_logic;
  signal signal_y: std_logic;
  signal signal_cin: std_logic;
  signal signal_cout: std_logic;
  signal signal_sum: std_logic;
  constant PERIOD: time := 1 ns;
begin
  full_adder1: component full_adder
  port map (
    x => signal_x,
    y => signal_y,
    cin => signal_cin,
    cout => signal_cout,
    sum => signal_sum);

  stimulus: process
    variable expected_sum : std_logic;
    variable expected_cout: std_logic;
  begin
    print("** Testing full_adder");

    wait for PERIOD;

    for x in std_logic range '0' to '1' loop
      for y in std_logic range '0' to '1' loop
        for cin in std_logic range '0' to '1' loop
          -- Load Signals
          signal_x   <= x; 
          signal_y   <= y; 
          signal_cin <= cin;

          -- Calculate Expected Sum and Carry Out Values
          expected_sum := x xor y xor cin;
          expected_cout := (x and y) or (x and cin) or (y and cin);

          wait for PERIOD;

          -- Validate Sum Value
          assert expected_sum = signal_sum 
            report "Wrong sum value, expected" & std_logic'image(expected_sum) & ". Actual: " & std_logic'image(signal_sum) & ". "
            severity FAILURE;

          -- Validate Carry Out Value
          assert expected_cout = signal_cout 
            report "Wrong carry out value, expected" & std_logic'image(expected_cout) & ". Actual: " & std_logic'image(signal_cout) & ". "
            severity FAILURE;
        end loop;
      end loop;
    end loop;

    wait for PERIOD;

    print("** full_adder test PASSED");

    finish;
  end process;
end architecture behavior;
