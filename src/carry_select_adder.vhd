-------------------------------------------------------------------------------
-- carry_select_adder
--
-- Splits addition into three pairs of n_bit_adders
-- The first n_bit_adder adds the lsb half of the number.
-- The next two n_bit_adders hold two results, one with the second half msb
-- result with carry in = 0 and another with the second half msb result with
-- carry in = 1. 
-- To select the correct msb half of the result, a multiplexer is used, where
-- the carry out of the lsb half will be the selector to the 2by1 multiplexer.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------
entity carry_select_adder is
  generic(
    SIZE : positive := 4);
  port (
    x   : in std_logic_vector(SIZE-1 downto 0);
    y   : in std_logic_vector(SIZE-1 downto 0);
    cin : in std_logic;
    cout: out std_logic;
    sum : out std_logic_vector(SIZE-1 downto 0));
end entity carry_select_adder;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture rtl of carry_select_adder is
  -------------------------------------------------------------------------------
  -- signals
  -------------------------------------------------------------------------------
  signal mux_select : std_logic;
  signal cout0      : std_logic;
  signal cout1      : std_logic;
  signal sum0       : std_logic_vector(SIZE-SIZE/2-1 downto 0);
  signal sum1       : std_logic_vector(SIZE-SIZE/2-1 downto 0);
begin
  -------------------------------------------------------------------------------
  -- full adder 1
  -------------------------------------------------------------------------------
  fa1: entity work.n_bit_full_adder 
  generic map(
    SIZE => SIZE/2 )
  port map (
    x    => x(SIZE/2-1 downto 0),
    y    => y(SIZE/2-1 downto 0),
    cin  => cin,
    cout => mux_select,
    sum  => sum(SIZE/2-1 downto 0));

  -------------------------------------------------------------------------------
  -- full adder mux select 0
  -------------------------------------------------------------------------------
  fa_mux_select_0: entity work.n_bit_full_adder 
  generic map (
    SIZE => SIZE-SIZE/2 )
  port map (
    x    => x(SIZE-1 downto SIZE/2),
    y    => y(SIZE-1 downto SIZE/2),
    cin  => '0',
    cout => cout0,
    sum  => sum0);

  -------------------------------------------------------------------------------
  -- full adder mux select 1
  -------------------------------------------------------------------------------
  fa_mux_select_1: entity work.n_bit_full_adder 
  generic map (
    SIZE => SIZE-SIZE/2 )
  port map (
    x    => x(SIZE-1 downto SIZE/2),
    y    => y(SIZE-1 downto SIZE/2),
    cin  => '1',
    cout => cout1,
    sum  => sum1);

  -------------------------------------------------------------------------------
  -- mux
  -------------------------------------------------------------------------------
  sum(SIZE-1 downto SIZE/2) <= sum0  when mux_select = '0' else sum1;
  cout                      <= cout0 when mux_select = '0' else cout1;
end architecture rtl;
