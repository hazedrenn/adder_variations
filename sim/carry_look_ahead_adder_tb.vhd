-------------------------------------------------------------------------------
-- carry_look_ahead_addert_tb.vhd
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use std.textio.all;

library work;
use work.sim_io_package.all;

-------------------------------------------------------------------------------
-- Entity
-------------------------------------------------------------------------------
entity carry_look_ahead_adder_tb is
end entity carry_look_ahead_adder_tb;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture behavior of carry_look_ahead_adder_tb is
  -------------------------------------------------------------------------------
  -- constants
  -------------------------------------------------------------------------------
  constant PERIOD: time := 1 ns;

  -------------------------------------------------------------------------------
  -- signals
  -------------------------------------------------------------------------------
	signal signal_a   : std_logic_vector(3 downto 0);
	signal signal_b   : std_logic_vector(3 downto 0);
	signal signal_cin : std_logic;
	signal signal_cout: std_logic;
	signal signal_sum : std_logic_vector(3 downto 0);
begin
  -------------------------------------------------------------------------------
  -- dut
  -------------------------------------------------------------------------------
  dut: entity work.carry_look_ahead_adder
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
    variable cin  : std_logic_vector(4 downto 0);
    variable sum  : std_logic_vector(3 downto 0);
    variable cout : std_logic;
  begin
    print("** Begin Test...");

    wait for PERIOD;

    for ii in 0 to signal_a'length**2-1 loop
      for jj in 0 to signal_b'length**2-1 loop
        for kk in 0 to 1 loop
          a   := std_logic_vector(to_unsigned(ii, a'length));
          b   := std_logic_vector(to_unsigned(jj, b'length));
          cin := std_logic_vector(to_unsigned(kk, cin'length));

          signal_a   <= a;
          signal_b   <= b;
          signal_cin <= cin(0);

          wait for PERIOD;
          
          for n in 0 to 3 loop
            sum(n)   := a(n) xor b(n) xor cin(n);
            cin(n+1) := (a(n) and b(n)) or (a(n) and cin(n)) or (b(n) and cin(n)); 
          end loop;

          cout := cin(4);

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
