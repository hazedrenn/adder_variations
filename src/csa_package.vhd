library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library work;
use work.general_package.all;

package csa_package is
  -- function csa_tree_height
  function csa_tree_height(
    number_of_inputs: natural)
    return natural;

  -- function csa_tree_number_of_inputs
  function csa_tree_number_of_inputs(
    height: natural)
    return natural;

  -- function generate csa enable
  function generate_csa_enable (
    num_of_inputs: natural;
    size_of_inputs: natural;
    height: natural) 
    return slvv_vector;

  -- function generate csa reroute row
  function generate_csa_reroute_row (
    num_of_inputs: natural;
    size_of_inputs: natural;
    height: natural) 
    return integer_3vector;

  -- function generate csa reroute col
  function generate_csa_reroute_col (
    num_of_inputs: natural;
    size_of_inputs: natural;
    height: natural) 
    return integer_3vector;
end package csa_package;

package body csa_package is
  --------------------------------------------------------------------------------
  -- function csa_tree_height
  --------------------------------------------------------------------------------
  function csa_tree_height(
    number_of_inputs: natural)
    return natural is
    variable height : natural;
  begin
    if number_of_inputs > 2 then
      return 1 + csa_tree_height(natural( ceil( real(2)/real(3)*real(number_of_inputs) )));
    else
      return 0;
    end if;
  end function csa_tree_height;

  --------------------------------------------------------------------------------
  -- function csa_tree_number_of_inputs
  --------------------------------------------------------------------------------
  function csa_tree_number_of_inputs(
    height: natural)
    return natural is
  begin
    if height = 0 then
      return 2; 
    else
      return 3*csa_tree_number_of_inputs(height-1)/2;
    end if;
  end function csa_tree_number_of_inputs;

  -----------------------------------------------------------------------------
  -- function generate csa enable
  -----------------------------------------------------------------------------
  function generate_csa_enable (
    num_of_inputs : natural;
    size_of_inputs: natural;
    height        : natural) 
    return slvv_vector is 
    variable csa_enable   : slvv_vector(height downto 0)(0 to num_of_inputs-1)(clog2(num_of_inputs)+size_of_inputs-1 downto 0) := (others => (others => (others => '0')));
    variable result       : slvv_vector(height downto 0)(0 to num_of_inputs-1)(clog2(num_of_inputs)+size_of_inputs-1 downto 0) := (others => (others => (others => '0')));
    variable csa_remainder: slvv_vector(height downto 0)(0 to num_of_inputs-1)(clog2(num_of_inputs)+size_of_inputs-1 downto 0) := (others => (others => (others => '0')));
    variable vector3x1    : std_logic_vector(2 downto 0);
    variable bit_count    : natural := 0;
  begin
    -- Initialize
    -- Based on the num_of_inputs x size_of_inputs matrix
    -- will fill this part of the matrix, while leaving 
    -- space for couts for the leftmost area of the matrix
    -- in later matrices of this matrices vector
    for row in 0 to csa_enable(height)'length-1 loop
      for col in size_of_inputs-1 downto 0 loop
        csa_enable(height)(row)(col) := '1';
        result(height)(row)(col) := '1';
      end loop;
    end loop;

    -- Fill the rest of the matrix array
    for h in height downto 1 loop
      for row in 0 to csa_enable(h)'length/3-1 loop
        for col in csa_enable(h)(row)'length-2 downto 0 loop
          -- check instances of 3x1 matrices in the matrix
          vector3x1 := csa_enable(h)(row*3)(col) & csa_enable(h)(row*3+1)(col) & csa_enable(h)(row*3+2)(col);
          if vector3x1 = "111" or vector3x1 = "110" then
            csa_enable(h-1)(row*3)(col)     := '1'; -- sum
            csa_enable(h-1)(row*3+1)(col+1) := '1'; -- cout
          elsif vector3x1 = "100" then
            csa_remainder(h-1)(row*3)(col) := '1';
          end if;
        end loop;
      end loop;
      
      -- Place remaining bits into enable matrix
      for row in num_of_inputs-(num_of_inputs mod 3) to num_of_inputs-1 loop
        for col in csa_enable(h)(row)'length-2 downto 0 loop
          csa_remainder(h-1)(row)(col) := csa_enable(h)(row)(col);
        end loop;
      end loop;

      -- Count '1's in each column of csa_enable and csa_remainder
      for col in csa_enable(h)(0)'length-1 downto 0 loop
        for row in 0 to csa_enable(h)'length-1 loop
          if csa_enable(h-1)(row)(col) = '1' then
            bit_count := bit_count + 1;
          end if;
          if csa_remainder(h-1)(row)(col) = '1' then
            bit_count := bit_count + 1;
          end if;
        end loop; 
        
        -- based on bit_count, keep adding bits into column
        for row in 0 to csa_enable(h)'length-1 loop
          if bit_count > 0 then
            bit_count := bit_count - 1;
            result(h-1)(row)(col) := '1';
          end if;
        end loop;
      end loop;

      -- update csa enable matrix with flush result
      csa_enable(h-1) := result(h-1);
    end loop;

    return csa_enable;
  end function;

  -----------------------------------------------------------------------------
  -- function generate csa reroute row
  -----------------------------------------------------------------------------
  function generate_csa_reroute_row (
    num_of_inputs : natural;
    size_of_inputs: natural;
    height        : natural) 
    return integer_3vector is 
    variable csa_enable   : slvv_vector    (height downto 0)(0 to num_of_inputs-1)(clog2(num_of_inputs)+size_of_inputs-1 downto 0) := generate_csa_enable(num_of_inputs, size_of_inputs, height);
    variable reroute_row  : integer_3vector(height downto 0)(0 to num_of_inputs-1)(clog2(num_of_inputs)+size_of_inputs-1 downto 0) := (others => (others => (others => num_of_inputs-1)));
    variable vector3x1    : std_logic_vector(2 downto 0);
    variable row_vector   : integer_vector (clog2(num_of_inputs)+size_of_inputs-1 downto 0) := (others => 0);
  begin
    -- Fill the rest of the matrix array
    for h in height downto 1 loop
      row_vector := (others => 0);
      for row in 0 to csa_enable(h)'length/3-1 loop
        for col in csa_enable(h)(row)'length-1 downto 0 loop
          -- check instances of 3x1 matrices in the matrix
          vector3x1 := csa_enable(h)(row*3)(col) & csa_enable(h)(row*3+1)(col) & csa_enable(h)(row*3+2)(col);
          if vector3x1 = "111" or vector3x1 = "110" then
            reroute_row(h)(row*3)(col) := row_vector(col);
            row_vector(col) := row_vector(col) + 1;
            reroute_row(h)(row*3+1)(col) := row_vector(col+1);
            row_vector(col+1) := row_vector(col+1) + 1;
          elsif vector3x1 = "100" then
            reroute_row(h)(row*3)(col) := row_vector(col);
            row_vector(col) := row_vector(col) + 1;
          end if;
        end loop;
      end loop;
      
      -- Place remaining bits into enable matrix
      for row in num_of_inputs-(num_of_inputs mod 3) to num_of_inputs-1 loop
        for col in csa_enable(h)(row)'length-1 downto 0 loop
          if csa_enable(h)(row)(col) = '1' then
          reroute_row(h)(row)(col) := row_vector(col);
          row_vector(col) := row_vector(col) + 1;
          end if;
        end loop; -- 2nd col loop
      end loop; -- 2nd row loop
    end loop; -- height loop

    return reroute_row;
  end function;

  -----------------------------------------------------------------------------
  -- function generate csa reroute col
  -----------------------------------------------------------------------------
  function generate_csa_reroute_col (
    num_of_inputs : natural;
    size_of_inputs: natural;
    height        : natural) 
    return integer_3vector is 
    variable csa_enable   : slvv_vector    (height downto 0)(0 to num_of_inputs-1)(clog2(num_of_inputs)+size_of_inputs-1 downto 0) := generate_csa_enable(num_of_inputs, size_of_inputs, height);
    variable reroute_col  : integer_3vector(height downto 0)(0 to num_of_inputs-1)(clog2(num_of_inputs)+size_of_inputs-1 downto 0) := (others => (others => (others => clog2(num_of_inputs)+size_of_inputs-1)));
    variable vector3x1    : std_logic_vector(2 downto 0);
  begin
    -- Fill the rest of the matrix array
    for h in height downto 1 loop
      for row in 0 to csa_enable(h)'length/3-1 loop
        for col in csa_enable(h)(row)'length-2 downto 0 loop
          -- check instances of 3x1 matrices in the matrix
          vector3x1 := csa_enable(h)(row*3)(col) & csa_enable(h)(row*3+1)(col) & csa_enable(h)(row*3+2)(col);
          if vector3x1 = "111" or vector3x1 = "110" then
            reroute_col(h)(row*3)(col) := col;
            reroute_col(h)(row*3+1)(col) := col+1;
          elsif vector3x1 = "100" then
            reroute_col(h)(row*3)(col) := col;
          end if;
        end loop;
      end loop;
      
      -- Place remaining bits into enable matrix
      for row in num_of_inputs-(num_of_inputs mod 3) to num_of_inputs-1 loop
        for col in csa_enable(h)(row)'length-2 downto 0 loop
          if csa_enable(h)(row)(col) = '1' then
          reroute_col(h)(row)(col) := col;
          end if;
        end loop; -- 2nd col loop
      end loop; -- 2nd row loop
    end loop; -- height loop

    return reroute_col;
  end function;
end package body csa_package;
