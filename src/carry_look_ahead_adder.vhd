-------------------------------------------------------------------------------
-- carry_look_ahead_adder
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------
entity carry_look_ahead_adder is
	port (
		a: in std_logic_vector(3 downto 0);
		b: in std_logic_vector(3 downto 0);
		cin: in std_logic;
		cout: out std_logic;
		sum: out std_logic_vector(3 downto 0)
	);
end entity carry_look_ahead_adder;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture rtl of carry_look_ahead_adder is
  -------------------------------------------------------------------------------
  -- signals
  -------------------------------------------------------------------------------
  signal g: std_logic_vector(3 downto 0);
  signal p: std_logic_vector(3 downto 0);
  signal c: std_logic_vector(4 downto 0);
begin
  p <= a xor b; --propagate
  g <= a and b; --generate

  -------------------------------------------------------------------------------
  -- carry generator
  -------------------------------------------------------------------------------
  c(0) <= cin;
  carry_gen: for i in 0 to c'length-2 generate
    c(i+1) <= g(i) or ( c(i) and p(i) );
  end generate carry_gen;
  cout <= c(4);

	sum <= p xor c(3 downto 0);
end rtl;



