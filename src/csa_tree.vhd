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
  -- CSA signals
  -- create an array of csa input matrices
  -- each index of this array is a csa input matrix
  -- the index number goes from MAX_HEIGHT downto 0, 0 being lowest height and is the result of the csa reduction
  signal csa_input    : slvv_vector(MAX_HEIGHT downto 0)(0 to NUM_OF_INPUTS-1)(clog2(NUM_OF_INPUTS) + SIZE_OF_INPUTS-1 downto 0);
  signal new_csa_input    : slvv_vector(MAX_HEIGHT downto 0)(0 to NUM_OF_INPUTS-1)(clog2(NUM_OF_INPUTS) + SIZE_OF_INPUTS-1 downto 0);

  -- create an array of enable matrices
  -- each index of this array is an enable matrix
  -- same index logic as csa input matrices
  -- used to csa reduce without depending on the value of the inputs, since doing so would change hardware logic constantly
  signal csa_enable   : slvv_vector(MAX_HEIGHT downto 0)(0 to NUM_OF_INPUTS-1)(clog2(NUM_OF_INPUTS) + SIZE_OF_INPUTS-1 downto 0);
  signal new_csa_enable    : slvv_vector(MAX_HEIGHT downto 0)(0 to NUM_OF_INPUTS-1)(clog2(NUM_OF_INPUTS) + SIZE_OF_INPUTS-1 downto 0);

  signal csa_in       : slvv_vector(MAX_HEIGHT downto 0)(0 to 2)(SIZE_OF_INPUTS-1 downto 0);
  signal csa_result   : slvv_vector(MAX_HEIGHT downto 0)(0 to 2)(SIZE_OF_INPUTS   downto 0);
  signal csa_sum      : slv_vector (MAX_HEIGHT downto 1)(SIZE_OF_INPUTS-1 downto 0);
  signal csa_cout     : slv_vector (MAX_HEIGHT downto 1)(SIZE_OF_INPUTS-1 downto 0);
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
  csa_in        (MAX_HEIGHT) <= inputs(0 to 2);
  leftover_bits (MAX_HEIGHT) <= (others => (others => '0'));
  
  -- initialize csa input matrix array
  csa_input_init_gen: for row in 0 to csa_input(MAX_HEIGHT)'length-1 generate
    csa_input_init_row_gen: for col in inputs(row)'length-1 downto 0 generate
      csa_input (MAX_HEIGHT)(row)(col) <= inputs(row)(col);
    end generate csa_input_init_row_gen;
  end generate csa_input_init_gen;

  -- initialize enable matrix array. fill all in this matrix with 1's
  csa_enable_init_gen: for row in 0 to csa_input(MAX_HEIGHT)'length-1 generate
    csa_input_init_row_gen: for col in inputs(row)'length-1 downto 0 generate
      csa_enable (MAX_HEIGHT)(row)(col) <= '1';
    end generate csa_input_init_row_gen;
  end generate csa_enable_init_gen;

  --------------------------------------------------------------------------------
  -- generate csa tree
  --------------------------------------------------------------------------------
  csa_tree_gen: for height in MAX_HEIGHT downto 1 generate
    -- reduce csa input vector using Full Adders and Half Adders
    csa_reduce_gen: for row in 0 to (csa_input(height)'length/3)-1 generate
      -- iterate through each 3x1 space in this csa input vector
      -- do not touch the space in the bottom-most row if it does not make a 3x1 vector
      -- reduce the 3x1 vector into a 1x2 vector (diagonal to represent it as a sum, carry
      csa_reduce_row_gen: for col in csa_input(height)(row)'length-2 downto 0 generate
        -- if all 3 are enabled, reduce using Full Adder
        fa: entity work.full_adder
        port map(
          x    => csa_input(height)(row*3)(col),
          y    => csa_input(height)(row*3+1)(col),
          cin  => csa_input(height)(row*3+2)(col),
          -- assign the results into a new csa input vector
          sum  => new_csa_input(height)(row*3)(col),
          cout => new_csa_input(height)(row*3+1)(col+1)
        );

        -- update enable matrix for each reduction
        -- if a reduction was used, add a 1x2 vector diagonal into new enable matrix
        new_csa_enable(height)(row*3)(col) <= '1';
        new_csa_enable(height)(row*3+1)(col+1) <= '1';
      end generate csa_reduce_row_gen;

      -- move all unused bits into new csa input vector
      -- make EXTRA sure not to assign unused bits into registers that have already been assigned
      -- you can tell by the new enable matrix if there is already a '1'
      -- format the inputs so that the bits are at the top-most position in their column
      -- may make another matrix possibly
      -- assign, then change the enable bit to that position
    -- rinse and repeat
    end generate csa_reduce_gen;

    csa1: entity work.carry_save_adder
      generic map(
        SIZE     => SIZE_OF_INPUTS)
      port map (
        csa_in   => csa_in(height),
        csa_sum  => csa_sum(height),
        csa_cout => csa_cout(height)
      );
    csa_result    (height-1) <= ( pad( leftover_bits (height)(1)(0 downto 0) & csa_sum (height), SIZE_OF_INPUTS+1 ), 
                                  pad( csa_cout      (height)                & "0",              SIZE_OF_INPUTS+1 ), 
                                  pad( inputs        (inputs'high),                              SIZE_OF_INPUTS+1 ) );

    csa_in_gen: for row in 0 to csa_in(height-1)'length-1 generate
      csa_in        (height-1)(row) <= csa_result(height-1)(row)(SIZE_OF_INPUTS-1 downto 0);
    end generate;

    leftover_gen: for row in 0 to leftover_bits(height-1)'length-1 generate
      leftover_bits (height-1)(row) <= csa_result(height-1)(row)(SIZE_OF_INPUTS   downto SIZE_OF_INPUTS);
    end generate;
  end generate csa_tree_gen;

  --------------------------------------------------------------------------------
  -- Ripple Carry Adder Mapping
  --------------------------------------------------------------------------------
  rca_y_in     <= csa_result(0)(1)(SIZE_OF_INPUTS downto 1);
  rca_x_in     <= csa_result(0)(0)(SIZE_OF_INPUTS downto 1);
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
