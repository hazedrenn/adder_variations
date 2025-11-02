-------------------------------------------------------------------------------
-- carry_skip_adder
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------
entity carry_skip_adder is
  port (
    a: in std_logic_vector(3 downto 0);
    b: in std_logic_vector(3 downto 0);
    cin: in std_logic;
    cout: out std_logic;
    sum: out std_logic_vector(3 downto 0)
  );
end entity carry_skip_adder;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture rtl of carry_skip_adder is
  -------------------------------------------------------------------------------
  -- signals
  -------------------------------------------------------------------------------
  signal p: std_logic_vector(3 downto 0);
  signal c: std_logic_vector(4 downto 0);
begin
  p <= a xor b; --propagate

  -------------------------------------------------------------------------------
  -- carry generator
  -------------------------------------------------------------------------------
  c(0) <= cin;

  fa_generate: for i in 0 to 3 generate
    fa: entity work.full_adder port map (
    x   => a(i), 
    y   => b(i),
    cin => c(i),
    cout=> c(i+1),
    sum => sum(i));
  end generate;

  cout <= c(4) when (and p) = '0' else c(0); 

  sum <= p xor c(3 downto 0);
end rtl;



