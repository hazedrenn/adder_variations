library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use std.textio.all;

package my_package is
	procedure print(s: string);

	type t_sample_record is record
		signal_e: std_logic;
	end record t_sample_record;

	function sample_function (
		input_vector: in std_logic_vector(3 downto 0))
		return std_logic;
end package my_package;

package body my_package is
	procedure print(s: string) is
		variable l: line;
	begin
		write(l, s);
		writeline(output, l);
	end procedure print;

	function sample_function (
		input_vector: in std_logic_vector(3 downto 0))
		return std_logic is
	begin
		return '0';
	end function sample_function;
end package body my_package;
