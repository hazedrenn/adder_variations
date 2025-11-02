-------------------------------------------------------------------------------
-- module carry_save_adder
--
-- Single Carry Save Adder modules are just Full Adders reconfigured to save
-- the carry out. This module allows parameterization of full adders so that
-- the carry out signals can be a vector output instead of a signal output,
-- which matches a N-bit Carry Save Adder behavior.
--
-- Carry Save adders take in 3 vector inputs: a, b, and cin. The addition
-- result will be saved as 2 vector output: sum and cout.
--
-- Using Carry Save Adders will save propagation time which is observed in
-- Ripple Carry Adders. However, since the output of the Carry Save Adder
-- will be 2 vector outputs, you must combine both Carry Out and Sum vectors 
-- to get the full result. This can be done using a Ripple Carry Adder or
-- another equivalent architecture.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------
entity carry_save_adder is
  generic(
    N : positive := 4);
  port (
    x   : in std_logic_vector(N-1 downto 0);
    y   : in std_logic_vector(N-1 downto 0);
    cin : in std_logic_vector(N-1 downto 0);
    cout: out std_logic_vector(N-1 downto 0);
    sum : out std_logic_vector(N-1 downto 0));
end entity carry_save_adder;

------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture rtl of carry_save_adder is
begin
  ------------------------------------------------------------------------------
  -- Full Adder Generator
  -------------------------------------------------------------------------------
  fa_generate: for ii in 0 to N-1 generate
    fa: entity work.full_adder port map (
      x => x(ii),
      y => y(ii),
      cin => cin(ii),
      cout => cout(ii),
      sum => sum(ii));
  end generate fa_generate;
end architecture rtl;
