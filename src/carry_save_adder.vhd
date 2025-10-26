library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity carry_save_adder is
  generic(
         N : positive := 4);
	port (
		x: in std_logic_vector(N-1 downto 0);
		y: in std_logic_vector(N-1 downto 0);
		cin: in std_logic_vector(N-1 downto 0);
		cout: out std_logic_vector(N-1 downto 0);
		sum: out std_logic_vector(N-1 downto 0)
	     );
end entity carry_save_adder;

architecture rtl of carry_save_adder is
  component full_adder is
    port(
      x: in std_logic;
      y: in std_logic;
      cin: in std_logic;
      cout: out std_logic;
      sum: out std_logic);
  end component;
begin
  fa_generate: for ii in 0 to N-1 generate
    fa: full_adder port map (
      x => x(ii),
      y => y(ii),
      cin => cin(ii),
      cout => cout(ii),
      sum => sum(ii));
  end generate fa_generate;
end architecture rtl;
