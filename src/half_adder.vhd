library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity half_adder is
	port(
		x: in std_logic;
		y: in std_logic;
		cout: out std_logic;
		sum: out std_logic
	    );
end half_adder;

architecture rtl of half_adder is
begin
	cout <= x and y;
	sum <= x or y;
end rtl;
