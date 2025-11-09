--------------------------------------------------------------------------------
-- csa_tree
--
-- This module uses carry save adders to add multiple k-bit numbers at once.
-- The design combines the use of carry save adders to reduce the number of
-- inputs down to 2. Then these 2 inputs are inserted into a k-bit ripple
-- carry adder.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.general_package.all;

-------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------
entity csa_tree is
  generic (
    NUM_OF_INPUTS  : positive := 3;
    SIZE_OF_INPUTS : positive := 4);
  port (
    inputs         : in  slv_vector(0 to NUM_OF_INPUTS-1)(SIZE_OF_INPUTS-1 downto 0);
    cout           : out std_logic;
    sum            : out std_logic_vector(SIZE_OF_INPUTS+clog2(NUM_OF_INPUTS)-1 downto 0));
end csa_tree;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture rtl of csa_tree is
  -------------------------------------------------------------------------------- 
  -- constants
  -------------------------------------------------------------------------------- 
  CONSTANT MAX_HEIGHT      : natural := csa_tree_height(NUM_OF_INPUTS);

  -------------------------------------------------------------------------------- 
  -- signals
  -------------------------------------------------------------------------------- 
  --signal results      : slvv_vector( MAX_HEIGHT downto 0 )(0 to NUM_OF_INPUTS   - 1)(SIZE_OF_INPUTS+clog2(NUM_OF_INPUTS)-1 downto 0) := (others => (others => (others => '0')));
  --signal result_couts : slvv_vector( MAX_HEIGHT downto 0 )(0 to NUM_OF_INPUTS   - 1)(SIZE_OF_INPUTS+clog2(NUM_OF_INPUTS)-1 downto 0) := (others => (others => (others => '0')));
  --signal csa_inputs   : slvv_vector( MAX_HEIGHT downto 1 )(0 to NUM_OF_INPUTS   - 1)(SIZE_OF_INPUTS-1 downto 0);
  --signal carry_outs   : slvv_vector( MAX_HEIGHT downto 1 )(0 to NUM_OF_INPUTS/3 - 1)(SIZE_OF_INPUTS-1 downto 0);
  --signal sums         : slvv_vector( MAX_HEIGHT downto 1 )(0 to NUM_OF_INPUTS/3 + NUM_OF_INPUTS mod 3  - 1)(SIZE_OF_INPUTS-1 downto 0); 
  --signal rca_in       : slv_vector( 0 to 1 )(SIZE_OF_INPUTS-1 downto 0);
  --signal shift_index  : integer_vector(MAX_HEIGHT downto 0) := (others => 0);
  --signal bit_count    : integer_2vector(MAX_HEIGHT downto 0)(0 to NUM_OF_INPUTS) := (others => (others => 0));

  -- CSA signals
  signal csa_in       : slvv_vector(MAX_HEIGHT downto 0)(0 to 2)(SIZE_OF_INPUTS-1 downto 0);
  signal csa_result   : slvv_vector(MAX_HEIGHT downto 0)(0 to 2)(SIZE_OF_INPUTS   downto 0);
  signal csa_sum      : slv_vector(MAX_HEIGHT downto 1)(SIZE_OF_INPUTS-1 downto 0);
  signal csa_cout     : slv_vector(MAX_HEIGHT downto 1)(SIZE_OF_INPUTS-1 downto 0);
  signal leftover_bits: slvv_vector(MAX_HEIGHT downto 0)(0 to 2)(0 downto 0);
  signal retired_bits : std_logic_vector(0 downto 0);

  -- Full Adder signals
  signal rca_x_in     : std_logic_vector(SIZE_OF_INPUTS-1 downto 0);
  signal rca_y_in     : std_logic_vector(SIZE_OF_INPUTS-1 downto 0);
  signal cout_fa      : std_logic;
  signal sum_fa       : std_logic_vector(SIZE_OF_INPUTS-1 downto 0);
begin
  --------------------------------------------------------------------------------
  -- initialize csa tree input
  --------------------------------------------------------------------------------
  csa_in(csa_in'high) <= inputs(0 to 2);
  leftover_bits(leftover_bits'high) <= (others => (others => '0'));

  --------------------------------------------------------------------------------
  -- generate csa tree
  --------------------------------------------------------------------------------
  csa_tree_gen: for height in MAX_HEIGHT downto 1 generate
    csa1: entity work.carry_save_adder
      generic map(
        SIZE     => SIZE_OF_INPUTS)
      port map (
        csa_in   => csa_in(height),
        csa_sum  => csa_sum(height),
        csa_cout => csa_cout(height)
      );
    csa_result    (height-1) <= ( pad( leftover_bits (height)(1)(0 downto 0) & csa_sum (height), SIZE_OF_INPUTS+1 ), 
                                  pad( csa_cout      (height)                & "0",              SIZE_OF_INPUTS+1 ),  -- "0" can be replaced with LSB of next input
                                  pad( inputs        (inputs'high),                              SIZE_OF_INPUTS+1 ) );
    csa_in        (height-1) <= ( csa_result(height-1)(0)(SIZE_OF_INPUTS-1 downto 0), 
                                  csa_result(height-1)(1)(SIZE_OF_INPUTS-1 downto 0), 
                                  csa_result(height-1)(2)(SIZE_OF_INPUTS-1 downto 0) );
    leftover_bits (height-1) <= ( csa_result(height-1)(0)(SIZE_OF_INPUTS   downto SIZE_OF_INPUTS),
                                  csa_result(height-1)(1)(SIZE_OF_INPUTS   downto SIZE_OF_INPUTS),
                                  csa_result(height-1)(2)(SIZE_OF_INPUTS   downto SIZE_OF_INPUTS) ); 
  end generate csa_tree_gen;


  --------------------------------------------------------------------------------
  -- Ripple Carry Adder Mapping
  --------------------------------------------------------------------------------
  rca_x_in     <= csa_result(0)(0)(SIZE_OF_INPUTS downto 1);
  rca_y_in     <= csa_result(0)(1)(SIZE_OF_INPUTS downto 1);
  retired_bits (retired_bits'length-1) <= csa_result(0)(0)(0);
  
  --------------------------------------------------------------------------------
  -- last stage Ripple Carry Adder
  --------------------------------------------------------------------------------
  fa1: entity work.n_bit_full_adder
    generic map (
      SIZE => SIZE_OF_INPUTS)
    port map (
      x    => rca_x_in,
      y    => rca_y_in,
      cin  => '0',
      cout => cout_fa,
      sum  => sum_fa);

  sum <= pad(cout_fa & sum_fa & retired_bits, sum'length);
end architecture rtl;
