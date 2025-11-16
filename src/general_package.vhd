library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

package general_package is
  -- type slv_vector: 2d std_logic vector
  type slv_vector is array (natural range<>) of std_logic_vector;
  -- type slvv_vector: 3d std_logic vector
  type slvv_vector is array (natural range<>) of slv_vector;
  -- type integer_2vector: 2d integer vector
  type integer_2vector is array (natural range<>) of integer_vector;
  -- type integer_3vector: 3d integer vector
  type integer_3vector is array (natural range<>) of integer_2vector;
  
  -- function clog2
  function clog2(
    number: positive)
    return natural;

  -- function flog2
  function flog2(
    number: positive)
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
