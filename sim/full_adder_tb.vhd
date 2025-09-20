library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

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

	process
	begin
		signal_x <= '0'; signal_y <= '0'; signal_cin <= '0'; wait for PERIOD;
		signal_x <= '0'; signal_y <= '0'; signal_cin <= '1'; wait for PERIOD;
		signal_x <= '0'; signal_y <= '1'; signal_cin <= '0'; wait for PERIOD;
		signal_x <= '0'; signal_y <= '1'; signal_cin <= '1'; wait for PERIOD;
		signal_x <= '1'; signal_y <= '0'; signal_cin <= '0'; wait for PERIOD;
		signal_x <= '1'; signal_y <= '0'; signal_cin <= '1'; wait for PERIOD;
		signal_x <= '1'; signal_y <= '1'; signal_cin <= '0'; wait for PERIOD;
		signal_x <= '1'; signal_y <= '1'; signal_cin <= '1'; wait for PERIOD;

		report "Finished test";
		finish;
	end process;
end architecture behavior;
