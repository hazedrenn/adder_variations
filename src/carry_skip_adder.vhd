library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity carry_skip_adder is
	port (
		a: in std_logic_vector(3 downto 0);
		b: in std_logic_vector(3 downto 0);
		cin: in std_logic;
		cout: out std_logic;
		sum: out std_logic_vector(3 downto 0)
	);
end entity carry_skip_adder;

architecture rtl of carry_skip_adder is
  signal g: std_logic_vector(3 downto 0);
  signal p: std_logic_vector(3 downto 0);
  signal c: std_logic_vector(4 downto 0);
begin
  p <= a xor b; --propagate
  g <= a and b; --generate

  --carry generator
  c(0) <= cin;
  c(1) <= g(0) or (c(0) and p(0));
  c(2) <= g(1) or (g(0) and p(1)) or (c(0) and p(0) and p(1));
  c(3) <= g(2) or (g(1) and p(2)) or (g(0) and p(1) and p(2)) or (c(0) and p(0) and p(1) and p(2));
  c(4) <= g(3) or (g(2) and p(3)) or (g(1) and p(2) and p(3)) or (g(0) and p(1) and p(2) and p(3)) or (c(0) and p(0) and p(1) and p(2) and p(3));
  cout <= c(0) when (and p = '1') else c(4);

	sum <= p xor c(3 downto 0);
end rtl;



