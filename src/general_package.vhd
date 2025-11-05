library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

package general_package is
  -- type slv_vector 2d vector
  type slv_vector is array (natural range<>) of std_logic_vector;
  -- type slvv_vector: 3d vector
  type slvv_vector is array (natural range<>) of slv_vector;
  
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
end package body general_package;
