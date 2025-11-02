-------------------------------------------------------------------------------
-- full_adder
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------
entity full_adder is
  port (
    x    : in std_logic;
    y    : in std_logic;
    cin  : in std_logic;
    cout : out std_logic;
    sum  : out std_logic);
end full_adder;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture rtl of full_adder is
begin
  cout <= (x and y) or (x and cin) or (y and cin);
  sum <= x xor y xor cin;
end rtl;
