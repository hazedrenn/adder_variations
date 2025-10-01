library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use std.textio.all;

entity cla_adder_tb is
end entity cla_adder_tb;

architecture behavior of cla_adder_tb is
  ---------------------------
  -- PROCEDURE: print
  ---------------------------
  procedure print(s: string) is
    variable l: line;
  begin
    write(l, s);
    writeline(output, l);
  end procedure print;
  ---------------------------
  -- COMPONENT: cla_adder
  ---------------------------
  component cla_adder is
	port (
		a: in std_logic_vector(3 downto 0);
		b: in std_logic_vector(3 downto 0);
		cin: in std_logic;
		cout: out std_logic;
		sum: out std_logic_vector(3 downto 0));
  end component cla_adder;
  --------------------------
  -- SIGNALS
  --------------------------
	signal signal_a: std_logic_vector(3 downto 0);
	signal signal_b: std_logic_vector(3 downto 0);
	signal signal_cin: std_logic;
	signal signal_cout: std_logic;
	signal signal_sum: std_logic_vector(3 downto 0);
  --------------------------
  -- CONSTANTS
  --------------------------
  constant PERIOD: time := 1 ns;
begin
  -----------------------------
  -- COMPONENT INSTANCE: cla_adder1
  -----------------------------
  cla_adder1: component cla_adder
  port map (
    a => signal_a,
    b => signal_b,
    cin => signal_cin,
    cout => signal_cout,
    sum => signal_sum);
  -----------------------------
  -- PROCESS: main
  -- main contains all the signal assignments for 
  -- the testbench. The results are printed out to
  -- for text-based confirmation.
  -----------------------------
  main: process
  begin
    print(LF&"Begin Test...");
    signal_a <= b"0000"; signal_b <= b"0001"; signal_cin <= '0';  wait for PERIOD;
    print(to_string(signal_a)&" + "&to_string(signal_b)&" = "&to_string(signal_sum));
    signal_a <= b"0010"; signal_b <= b"1001"; signal_cin <= '0'; wait for PERIOD;
    print(to_string(signal_a)&" + "&to_string(signal_b)&" = "&to_string(signal_sum));
    signal_a <= b"0110"; signal_b <= b"0101"; signal_cin <= '0'; wait for PERIOD;
    print(to_string(signal_a)&" + "&to_string(signal_b)&" = "&to_string(signal_sum));
    signal_a <= b"0001"; signal_b <= b"0101"; signal_cin <= '0'; wait for PERIOD;
    print(to_string(signal_a)&" + "&to_string(signal_b)&" = "&to_string(signal_sum));
    wait for PERIOD;
    report "Finished test";
    finish;
  end process;
end architecture behavior;
