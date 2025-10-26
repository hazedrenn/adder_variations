library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use std.textio.all;

library work;
use work.my_package.all;

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

  procedure adder_result(
    x: std_logic;
    y: std_logic;
    cout: std_logic; 
    sum: std_logic) is
  begin
    print(std_logic'image(x)&" + "& std_logic'image(y)&" = "&std_logic'image(cout)&std_logic'image(sum));
  end procedure adder_result;
  
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
    signal_x <= '0'; signal_y <= '0'; wait for PERIOD;
    adder_result(signal_x, signal_y, signal_cout, signal_sum);
    assert signal_cout = '0' and signal_sum = '0' 
      report "sum is "&std_logic'image(signal_cout)&std_logic'image(signal_sum)&"should be 00" 
      severity FAILURE;
    signal_x <= '0'; signal_y <= '1'; wait for PERIOD;
    adder_result(signal_x, signal_y, signal_cout, signal_sum);
    signal_x <= '1'; signal_y <= '0'; wait for PERIOD;
    adder_result(signal_x, signal_y, signal_cout, signal_sum);
    signal_x <= '1'; signal_y <= '1'; wait for PERIOD;
    adder_result(signal_x, signal_y, signal_cout, signal_sum);
    wait for PERIOD;

    print("** FINISHED half_adder test...");
    finish;
  end process;
end architecture behavior;
