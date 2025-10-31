-------------------------------------------------------------------------------
-- n_bit_full_adder
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
entity n_bit_full_adder_tb is
  generic( 
    SIZE: positive :=4 );
end entity n_bit_full_adder_tb;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture behavior of n_bit_full_adder_tb is
  -------------------------------------------------------------------------------
  -- constants
  -------------------------------------------------------------------------------
  constant PERIOD: time := 1 ns;

  -------------------------------------------------------------------------------
  -- signals
  -------------------------------------------------------------------------------
  signal signal_x   : std_logic_vector(SIZE-1 downto 0);
  signal signal_y   : std_logic_vector(SIZE-1 downto 0);
  signal signal_cin : std_logic;
  signal signal_cout: std_logic;
  signal signal_sum : std_logic_vector(SIZE-1 downto 0);
begin
  -------------------------------------------------------------------------------
  -- dut
  -------------------------------------------------------------------------------
  dut: entity work.n_bit_full_adder
  generic map(
    SIZE     => SIZE)
  port map (
    x     => signal_x,
    y     => signal_y,
    cin   => signal_cin,
    cout  => signal_cout,
    sum   => signal_sum);

  -------------------------------------------------------------------------------
  -- stimulus
  -------------------------------------------------------------------------------
  stimulus: process
    variable x   : std_logic_vector(SIZE-1 downto 0);
    variable y   : std_logic_vector(SIZE-1 downto 0);
    variable cin : std_logic_vector(SIZE   downto 0);
    variable sum : std_logic_vector(SIZE-1 downto 0);
    variable cout: std_logic;
  begin
    print("** Testing n_bit_full_adder");

    -- Validate all possible input combinations
    for ii in 0 to SIZE**2-1 loop
      for jj in 0 to SIZE**2-1 loop
        for kk in 0 to 1 loop
          x   := std_logic_vector(to_unsigned(ii, x'length));
          y   := std_logic_vector(to_unsigned(jj, y'length));
          cin := std_logic_vector(to_unsigned(kk, cin'length));

          signal_x   <= x;
          signal_y   <= y;
          signal_cin <= cin(0);

          wait for PERIOD;

          -- Generate expected sum and cout
          for n in 0 to SIZE-1 loop
            sum(n)   := x(n) xor y(n) xor cin(n);
            cin(n+1) := (x(n) and y(n)) or (x(n) and cin(n)) or (y(n) and cin(n));
            cout     := cin(n+1);
          end loop;

          -- Verify sum and cout
          assert signal_sum  = sum
            report "Error: Incorrect sum. Actual "& to_string(signal_sum) &". Expected "& to_string(sum)
            severity FAILURE;

          assert signal_cout = cout
            report "Error: Incorrect carry out. Actual "& to_string(signal_cout) &". Expected "& to_string(cout)
            severity FAILURE;
        end loop;
      end loop;
    end loop;

    wait for PERIOD;
    print("** FINISHED n_bit_full_adder test");
    finish;
  end process;
end architecture behavior;
