-------------------------------------------------------------------------------
-- n_bit_full_adder
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------
entity n_bit_full_adder is
  generic(
    SIZE : positive := 4);
  port (
    x    : in std_logic_vector(SIZE-1 downto 0);
    y    : in std_logic_vector(SIZE-1 downto 0);
    cin  : in std_logic;
    cout : out std_logic;
    sum  : out std_logic_vector(SIZE-1 downto 0));
end entity n_bit_full_adder;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture rtl of n_bit_full_adder is
  signal c : std_logic_vector(SIZE downto 0);
begin
  -------------------------------------------------------------------------------
  -- full adder generator
  -------------------------------------------------------------------------------
  c(0) <= cin;
  fa_generate: for n in 0 to SIZE-1 generate
    fa: entity work.full_adder port map (
      x    => x(n),
      y    => y(n),
      cin  => c(n),
      cout => c(n+1),
      sum  => sum(n));
  end generate fa_generate;
  cout <= c(SIZE);
end architecture rtl;
