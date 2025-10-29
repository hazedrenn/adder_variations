library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use std.textio.all;

library work;
use work.sim_io_package.all;

entity half_adder_tb is
end entity half_adder_tb;

architecture behavior of half_adder_tb is
  component half_adder is
  port(
    x: in std_logic;
    y: in std_logic;
    cout: out std_logic;
    sum: out std_logic);
  end component half_adder;

  signal signal_x: std_logic;
  signal signal_y: std_logic;
  signal signal_cout: std_logic;
  signal signal_sum: std_logic;

  constant PERIOD: time := 1 ns;
begin
  half_adder1: component half_adder
  port map (
    x => signal_x,
    y => signal_y,
    cout => signal_cout,
    sum => signal_sum);

  process
  begin
    print("** Testing half_adder...");

    wait for PERIOD;

    for ii in std_logic range '0' to '1' loop
      for jj in std_logic range '0' to '1' loop
        signal_x <= ii;
        signal_y <= jj;

        wait for PERIOD;

        print(std_logic'image(signal_x) & std_logic'image(signal_y));
        assert signal_cout = (ii and jj)
          report "Error: Carry Out is "& std_logic'image(signal_cout) &". Expected "& std_logic'image(ii and jj) &"."
          severity FAILURE;

        assert signal_sum = (ii xor jj)
          report "Error: Sum is "& std_logic'image(signal_sum) &". Expected "& std_logic'image(ii xor jj) &"."
          severity FAILURE;
      end loop;
    end loop;
      
    wait for PERIOD;

    print("** FINISHED half_adder test...");
    finish;
  end process;
end architecture behavior;
