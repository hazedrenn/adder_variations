library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

library work;
use work.sim_io_package.all;

entity carry_save_adder_tb is
  generic( 
    N: positive :=4 );
end entity carry_save_adder_tb;

architecture behavior of carry_save_adder_tb is
  component carry_save_adder is
  generic ( 
    N : positive := N);
  port (
    x   : in  std_logic_vector(N-1 downto 0);
    y   : in  std_logic_vector(N-1 downto 0);
    cin : in  std_logic_vector(N-1 downto 0);
    cout: out std_logic_vector(N-1 downto 0);
    sum : out std_logic_vector(N-1 downto 0));
  end component carry_save_adder;

  signal signal_x   : std_logic_vector(N-1 downto 0);
  signal signal_y   : std_logic_vector(N-1 downto 0);
  signal signal_cin : std_logic_vector(N-1 downto 0);
  signal signal_cout: std_logic_vector(N-1 downto 0);
  signal signal_sum : std_logic_vector(N-1 downto 0);
  constant PERIOD: time := 1 ns;
begin
  carry_save_adder1: component carry_save_adder
  port map (
    x     => signal_x,
    y     => signal_y,
    cin   => signal_cin,
    cout  => signal_cout,
    sum   => signal_sum);

  stimulus: process
    variable x   : std_logic_vector(N-1 downto 0);
    variable y   : std_logic_vector(N-1 downto 0);
    variable cin : std_logic_vector(N-1 downto 0);
    variable sum : std_logic_vector(N-1 downto 0);
    variable cout: std_logic_vector(N-1 downto 0);
  begin
    print("** Testing carry_save_adder");

    for ii in 0 to N**2-1 loop
      for jj in 0 to N**2-1 loop
        for kk in 0 to N**2-1 loop
          x   := std_logic_vector(to_unsigned(ii, x'length));
          y   := std_logic_vector(to_unsigned(jj, y'length));
          cin := std_logic_vector(to_unsigned(kk, cin'length));


          signal_x   <= x;
          signal_y   <= y;
          signal_cin <= cin;

          wait for PERIOD;

          sum := (x xor y xor cin);
          cout := (x and y) or (x and cin) or (y and cin);

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

    print("** FINISHED carry_save_adder test");

    finish;
  end process;
end architecture behavior;
