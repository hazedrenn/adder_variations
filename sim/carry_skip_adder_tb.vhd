-------------------------------------------------------------------------------
-- carry_skip_adder_tb
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use std.textio.all;

library work;
use work.sim_io_package.all;

-------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------
entity carry_skip_adder_tb is
end entity carry_skip_adder_tb;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture behavior of carry_skip_adder_tb is
  -------------------------------------------------------------------------------
  -- constants
  -------------------------------------------------------------------------------
  constant PERIOD: time := 1 ns;

  -------------------------------------------------------------------------------
  -- signals
  -------------------------------------------------------------------------------
  signal signal_a: std_logic_vector(3 downto 0);
  signal signal_b: std_logic_vector(3 downto 0);
  signal signal_cin: std_logic;
  signal signal_cout: std_logic;
  signal signal_sum: std_logic_vector(3 downto 0);
begin
  -------------------------------------------------------------------------------
  -- dut
  -------------------------------------------------------------------------------
  dut: entity work.carry_skip_adder
  port map (
    a => signal_a,
    b => signal_b,
    cin => signal_cin,
    cout => signal_cout,
    sum => signal_sum);

  -------------------------------------------------------------------------------
  -- stimulus
  -------------------------------------------------------------------------------
  stimulus: process
    variable a    : std_logic_vector(3 downto 0);
    variable b    : std_logic_vector(3 downto 0);
    variable cout : std_logic;
    variable cin  : std_logic;
    variable sum  : std_logic_vector(3 downto 0);
  begin
    print("** Begin Test...");

    wait for PERIOD;

    -- Test every input combination for a, b and cin
    for ii in 0 to signal_a'length**2-1 loop
      for jj in 0 to signal_b'length**2-1 loop
        for kk in std_logic range '0' to '1' loop
          a   := std_logic_vector(to_unsigned(ii, a'length));
          b   := std_logic_vector(to_unsigned(jj, b'length));
          cin := kk;

          signal_a   <= a;
          signal_b   <= b;
          signal_cin <= cin;

          wait for PERIOD;

          -- Generate expected sum and cout
          for n in 0 to sum'length-1 loop
            sum(n) := a(n) xor b(n) xor cin;
            cout   := (a(n) and b(n)) or (a(n) and cin) or (b(n) and cin);
            cin    := cout;
          end loop;

          -- Verify adder results
          assert signal_sum = sum
            report "Error: Incorrect sum. Actual: "& to_string(signal_sum) &". Expected: "& to_string(sum) &"."
            severity FAILURE;
          assert signal_cout = cout
            report "Error: Incorrect carry out. Actual: "& to_string(signal_cout) &". Expected: "& to_string(cout) &"."
            severity FAILURE;
        end loop;
      end loop;
    end loop;

    print("** Finished Test...");
    wait for PERIOD;
    finish;
  end process;
end architecture behavior;
