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
entity csa_tree_pipelined is
  generic (
    NUM_OF_INPUTS  : positive := 8;
    SIZE_OF_INPUTS : positive := 4);
  port (
    clock          : in  std_logic;
    inputs         : in  slv_vector(0 to NUM_OF_INPUTS-1)(SIZE_OF_INPUTS-1 downto 0);
    cout           : out std_logic;
    outputs        : out slvv_vector(csa_tree_height(NUM_OF_INPUTS) downto 0)(0 to NUM_OF_INPUTS-1)(clog2(NUM_OF_INPUTS)+SIZE_OF_INPUTS-1 downto 0);
    sum            : out std_logic_vector(SIZE_OF_INPUTS+clog2(NUM_OF_INPUTS)-1 downto 0));
end csa_tree_pipelined;


-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture rtl of csa_tree_pipelined is
  -------------------------------------------------------------------------------- 
  -- constants
  -------------------------------------------------------------------------------- 
  constant MAX_HEIGHT : natural := csa_tree_height(NUM_OF_INPUTS);
  constant SUM_LENGTH : natural := clog2(NUM_OF_INPUTS)+SIZE_OF_INPUTS;
  constant csa_enable : slvv_vector    (MAX_HEIGHT downto 0)(0 to NUM_OF_INPUTS-1)(SUM_LENGTH-1 downto 0) := generate_csa_enable     (NUM_OF_INPUTS, SIZE_OF_INPUTS, MAX_HEIGHT);
  constant csa_row    : integer_3vector(MAX_HEIGHT downto 0)(0 to NUM_OF_INPUTS-1)(SUM_LENGTH-1 downto 0) := generate_csa_reroute_row(NUM_OF_INPUTS, SIZE_OF_INPUTS, MAX_HEIGHT);
  constant csa_col    : integer_3vector(MAX_HEIGHT downto 0)(0 to NUM_OF_INPUTS-1)(SUM_LENGTH-1 downto 0) := generate_csa_reroute_col(NUM_OF_INPUTS, SIZE_OF_INPUTS, MAX_HEIGHT);

  -------------------------------------------------------------------------------- 
  -- signals
  -------------------------------------------------------------------------------- 
  -- CSA signals
  signal csa_input    : slvv_vector(MAX_HEIGHT downto 0)(0 to NUM_OF_INPUTS-1)(SUM_LENGTH-1 downto 0) := (others=>(others=>(others=>'0')));

  -- Full Adder signals
  signal cout_fa      : std_logic;
  signal sum_fa       : std_logic_vector(clog2(NUM_OF_INPUTS)+SIZE_OF_INPUTS-1 downto 0);
begin
  --------------------------------------------------------------------------------
  -- Generate CSA Tree
  --------------------------------------------------------------------------------
  csa_tree_pipelined_proc: process(clock) 
    variable new_row : natural;
    variable new_col : natural;
    variable sumVar  : std_logic;
    variable coutVar : std_logic;
    variable ena     : std_logic_vector(0 to 2);
    variable input   : std_logic_vector(0 to 2);
  begin
    if rising_edge(clock) then
      for row in 0 to csa_input(MAX_HEIGHT)'length-1 loop
        csa_input(MAX_HEIGHT)(row) <= pad(inputs(row), SUM_LENGTH);
      end loop;

      for height in MAX_HEIGHT downto 1 loop
        for row in 0 to (csa_input(height)'length/3)-1 loop
          for col in csa_input(height)(row)'length-2 downto 0 loop
            ena(0)   := csa_enable(height)(row*3)(col);
            ena(1)   := csa_enable(height)(row*3+1)(col);
            ena(2)   := csa_enable(height)(row*3+2)(col);

            input(0) := csa_input (height)(row*3)(col);
            input(1) := csa_input (height)(row*3+1)(col);
            input(2) := csa_input (height)(row*3+2)(col);

            if ena = "111" then
              new_row := csa_row(height)(row*3)(col);
              new_col := csa_col(height)(row*3)(col);
              sumVar  := input(0) xor input(1) xor input(2);
              csa_input(height-1)(new_row)(new_col) <= sumVar;

              new_row := csa_row(height)(row*3+1)(col);
              new_col := csa_col(height)(row*3+1)(col);
              coutVar := (input(0) and input(1)) or (input(0) and input(2)) or (input(1) and input(2));
              csa_input(height-1)(new_row)(new_col) <= coutVar;

            elsif ena = "110" then
              new_row := csa_row(height)(row*3)(col);
              new_col := csa_col(height)(row*3)(col);
              sumVar  := input(0) xor input(1);
              csa_input(height-1)(new_row)(new_col) <= sumVar;

              new_row := csa_row(height)(row*3+1)(col);
              new_col := csa_col(height)(row*3+1)(col);
              coutVar := input(0) and input(1);
              csa_input(height-1)(new_row)(new_col) <= coutVar;

            elsif ena = "100" then
              new_row := csa_row(height)(row*3)(col);
              new_col := csa_col(height)(row*3)(col);
              csa_input(height-1)(new_row)(new_col) <= input(0);
            end if; 
          end loop; -- col loop
        end loop; -- row loop

        for row in csa_input(height)'length-(csa_input(height)'length mod 3) to csa_input(height)'length-1 loop
          for col in csa_input(height)(row)'length-2 downto 0 loop
            ena(0)   := csa_enable(height)(row)(col);
            input(0) := csa_input(height)(row)(col);

            if ena(0) = '1' then
              new_row := csa_row(height)(row)(col);
              new_col := csa_col(height)(row)(col);
              csa_input(height-1)(new_row)(new_col) <= input(0);
            end if;
          end loop; -- col loop 2
        end loop; -- row loop 2
      end loop; -- height loop
    end if;
  end process csa_tree_pipelined_proc;

  outputs <= csa_input;


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


  --------------------------------------------------------------------------------
  -- Final Sum Result process
  --------------------------------------------------------------------------------
  sum_result_proc: process(clock)
  begin
    if rising_edge(clock) then
      sum <= sum_fa;
    end if;
  end process;
end architecture rtl;
