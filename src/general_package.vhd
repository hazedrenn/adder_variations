library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

package general_package is
  -- type slv_vector 2d vector
  type slv_vector is array (natural range<>) of std_logic_vector;
  -- type slvv_vector: 3d vector
  type slvv_vector is array (natural range<>) of slv_vector;
  -- type integer_2vector: 2d vector
  type integer_2vector is array (natural range<>) of integer_vector;
  
  -- function clog2
  function clog2(
    number: positive)
    return natural;

  -- function flog2
  function flog2(
    number: positive)
    return natural;

  -- function csa_tree_height
  function csa_tree_height(
    number_of_inputs: natural)
    return natural;

  -- function csa_tree_number_of_inputs
  function csa_tree_number_of_inputs(
    height: natural)
    return natural;

  -- function pad
  function pad(
    slv: std_logic_vector;
    size: natural)
    return std_logic_vector;

  -- function count_trailing_zeroes
  function count_trailing_zeroes(
    slv: std_logic_vector)
    return natural;

  -- function max
  function max(
    num1: integer;
    num2: integer)
    return integer;
end package general_package;

package body general_package is
  -- function clog2
  function clog2(
    number: positive)
    return natural is
    variable log_result: natural := 0;
  begin
    while 2**log_result < number loop
      log_result := log_result + 1;
    end loop;
    return log_result;
  end function clog2;

  -- function flog2
  function flog2(
    number: positive)
    return natural is
    variable log_result: natural := 0;
  begin
    while 2**log_result < number loop
      log_result := log_result + 1;
    end loop;
    if 2**log_result > number then
      return log_result-1;
    end if;
    return log_result;
  end function flog2;

  -- function csa_tree_height
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

  -- function csa_tree_number_of_inputs
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

  -- function pad
  function pad(
    slv: std_logic_vector;
    size: natural)
    return std_logic_vector is
    variable slv_new: std_logic_vector(size-1 downto 0);
  begin
    if slv'length >= size then
      return slv;
    end if;
    slv_new(slv'length-1 downto 0)              := slv;
    slv_new(slv_new'length-1 downto slv'length) := (others => '0');
    return slv_new;
  end function;

  -- function count_trailing_zeroes
  function count_trailing_zeroes(
    slv: std_logic_vector)
    return natural is
    variable num_of_trailing_zeroes: natural := 0;
  begin
    for i in 0 to slv'length-1 loop
      if or slv(i downto 0) = '0' then
        num_of_trailing_zeroes := i+1;
      end if;
    end loop;
    return num_of_trailing_zeroes;
  end function;

  -- function max
  function max(
    num1: integer;
    num2: integer)
    return integer is
  begin
    if num1 > num2 then
      return num1;
    end if;
    return num2;
  end function;
end package body general_package;
