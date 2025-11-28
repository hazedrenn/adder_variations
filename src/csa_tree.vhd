--------------------------------------------------------------------------------
-- csa tree module
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
use work.csa_package.all;

-------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------
entity csa_tree is
  generic (
    NUM_OF_INPUTS  : positive := 8;
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
  constant MAX_HEIGHT   : natural := csa_tree_height(NUM_OF_INPUTS);
  constant SUM_LENGTH   : natural := clog2(NUM_OF_INPUTS)+SIZE_OF_INPUTS;
  constant csa_enable   : slvv_vector    (MAX_HEIGHT downto 0)(0 to NUM_OF_INPUTS-1)(SUM_LENGTH-1 downto 0) := generate_csa_enable     (NUM_OF_INPUTS, SIZE_OF_INPUTS, MAX_HEIGHT);
  constant csa_row      : integer_3vector(MAX_HEIGHT downto 0)(0 to NUM_OF_INPUTS-1)(SUM_LENGTH-1 downto 0) := generate_csa_reroute_row(NUM_OF_INPUTS, SIZE_OF_INPUTS, MAX_HEIGHT);
  constant csa_col      : integer_3vector(MAX_HEIGHT downto 0)(0 to NUM_OF_INPUTS-1)(SUM_LENGTH-1 downto 0) := generate_csa_reroute_col(NUM_OF_INPUTS, SIZE_OF_INPUTS, MAX_HEIGHT);

  -------------------------------------------------------------------------------- 
  -- signals
  -------------------------------------------------------------------------------- 
  -- CSA signals
  signal csa_input    : slvv_vector(MAX_HEIGHT downto 0)(0 to NUM_OF_INPUTS-1)(clog2(NUM_OF_INPUTS)+SIZE_OF_INPUTS-1 downto 0) := (others=>(others=>(others=>'0')));

  -- Full Adder signals
  signal cout_fa      : std_logic;
  signal sum_fa       : std_logic_vector(clog2(NUM_OF_INPUTS)+SIZE_OF_INPUTS-1 downto 0);
begin
  --------------------------------------------------------------------------------
  -- Initialize CSA Tree Inputs
  --------------------------------------------------------------------------------
  csa_input_init_gen: for row in 0 to csa_input(MAX_HEIGHT)'length-1 generate
    csa_input_init_row_gen: for col in inputs(row)'length-1 downto 0 generate
      csa_input (MAX_HEIGHT)(row)(col) <= inputs(row)(col);
    end generate csa_input_init_row_gen;
  end generate csa_input_init_gen;


  --------------------------------------------------------------------------------
  -- Generate CSA Tree
  --------------------------------------------------------------------------------
  csa_tree_gen: for height in MAX_HEIGHT downto 1 generate
    -- Reduce CSA input vector using Full Adders and Half Adders
    csa_reduce_gen: for row in 0 to (csa_input(height)'length/3)-1 generate
      -- Iterate through each 3x1 space in this CSA input vector
      csa_reduce_row_gen: for col in csa_input(height)(row)'length-2 downto 0 generate
        -- If all 3 are enabled, reduce using Full Adder
        fa_gen: if csa_enable(height)(row*3)(col)   = '1' and 
                   csa_enable(height)(row*3+1)(col) = '1' and 
                   csa_enable(height)(row*3+2)(col) = '1' generate
          fa: entity work.full_adder
          port map(
            x    => csa_input(height)(row*3)(col),
            y    => csa_input(height)(row*3+1)(col),
            cin  => csa_input(height)(row*3+2)(col),
            sum  => csa_input(height-1)
                             (csa_row(height)(row*3)(col))
                             (csa_col(height)(row*3)(col)),
            cout => csa_input(height-1)
                             (csa_row(height)(row*3+1)(col))
                             (csa_col(height)(row*3+1)(col))
          );
        -- If only 2 are enabled, reduce using Half Adder
        elsif csa_enable(height)(row*3)(col)   = '1' and 
              csa_enable(height)(row*3+1)(col) = '1' generate
          ha: entity work.half_adder
          port map(  
            x    => csa_input(height)(row*3)(col),
            y    => csa_input(height)(row*3+1)(col),
            sum  => csa_input(height-1)
                             (csa_row(height)(row*3)(col))
                             (csa_col(height)(row*3)(col)),
            cout => csa_input(height-1)
                             (csa_row(height)(row*3+1)(col))
                             (csa_col(height)(row*3+1)(col))
          );
        -- Move all unused bits into new CSA input vector
        elsif csa_enable(height)(row*3)(col) = '1' generate
          csa_input(height-1)
                   (csa_row(height)(row*3)(col))
                   (csa_col(height)(row*3)(col)) <= csa_input(height)(row*3)(col);
        end generate fa_gen;
      end generate csa_reduce_row_gen;
    end generate csa_reduce_gen;

    -- Rows not reduced through CSA reduction are passed through to the next height level
    csa_reduce_remainder_gen: for row in csa_input(height)'length-(csa_input(height)'length mod 3) to csa_input(height)'length-1 generate
      csa_reduce_remainder_row_gen: for col in csa_input(height)(row)'length-2 downto 0 generate
        csa_reduce_remainder_row_en_gen: if csa_enable(height)(row)(col) = '1' generate
          csa_input(height-1)
                   (csa_row(height)(row)(col))
                   (csa_col(height)(row)(col)) <= csa_input(height)(row)(col);
        end generate csa_reduce_remainder_row_en_gen;
      end generate csa_reduce_remainder_row_gen;
    end generate csa_reduce_remainder_gen;
  end generate csa_tree_gen;
  

  --------------------------------------------------------------------------------
  -- Last Stage Ripple Carry Adder
  --------------------------------------------------------------------------------
  fa1: entity work.n_bit_full_adder
    generic map (
      SIZE => csa_input(0)(1)'length)
    port map (
      x    => csa_input(0)(0),
      y    => csa_input(0)(1),
      cin  => '0',
      cout => cout_fa,
      sum  => sum_fa);

  -- Final sum result
  sum <= sum_fa;
end architecture rtl;
