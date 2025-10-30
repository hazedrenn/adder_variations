-------------------------------------------------------------------------------
-- half_adder_tb
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use std.textio.all;

library work;
use work.sim_io_package.all;

-------------------------------------------------------------------------------
-- half_adder_tb
-------------------------------------------------------------------------------
entity half_adder_tb is
end entity half_adder_tb;

-------------------------------------------------------------------------------
-- half_adder_tb
-------------------------------------------------------------------------------
architecture behavior of half_adder_tb is
  -------------------------------------------------------------------------------
  -- constants
  -------------------------------------------------------------------------------
  constant PERIOD: time := 1 ns;

  -------------------------------------------------------------------------------
  -- signals
  -------------------------------------------------------------------------------
  signal signal_x   : std_logic;
  signal signal_y   : std_logic;
  signal signal_cout: std_logic;
  signal signal_sum : std_logic;
begin
  -------------------------------------------------------------------------------
  -- dut
  -------------------------------------------------------------------------------
  dut: entity work.half_adder
  port map (
    x => signal_x,
    y => signal_y,
    cout => signal_cout,
    sum => signal_sum);

  -------------------------------------------------------------------------------
  -- stimulus
  -------------------------------------------------------------------------------
  stimulus: process
    variable sum : std_logic;
    variable cout: std_logic;
  begin
    print("** Testing half_adder...");

    wait for PERIOD;

    -- Validate all combinations
    for xx in std_logic range '0' to '1' loop
      for yy in std_logic range '0' to '1' loop
        signal_x <= xx;
        signal_y <= yy;

        wait for PERIOD;

        -- Generate expected sum and cout
        sum := xx xor yy;
        cout := xx and yy;

        -- Validate sum and cout
        assert signal_sum = sum
          report "Error: Sum is "& std_logic'image(signal_sum) &". Expected "& std_logic'image(sum) &"."
          severity FAILURE;

        assert signal_cout = cout
          report "Error: Carry Out is "& std_logic'image(signal_cout) &". Expected "& std_logic'image(cout) &"."
          severity FAILURE;
      end loop;
    end loop;
      
    print("** FINISHED half_adder test...");
    wait for PERIOD;
    finish;
  end process;
end architecture behavior;
