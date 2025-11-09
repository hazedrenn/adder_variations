-------------------------------------------------------------------------------
-- carry_save_adder_tb
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

library work;
use work.sim_io_package.all;
use work.general_package.all;

-------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------
entity carry_save_adder_tb is
  generic( 
    SIZE: positive :=4 );
end entity carry_save_adder_tb;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture behavior of carry_save_adder_tb is
  -------------------------------------------------------------------------------
  -- constants
  -------------------------------------------------------------------------------
  constant PERIOD: time := 1 ns;

  -------------------------------------------------------------------------------
  -- signals
  -------------------------------------------------------------------------------
  signal signal_csa_in  : slv_vector(0 to 2)(SIZE-1 downto 0);
  signal signal_csa_sum : std_logic_vector(SIZE-1 downto 0);
  signal signal_csa_cout: std_logic_vector(SIZE-1 downto 0);
begin
  -------------------------------------------------------------------------------
  -- dut
  -------------------------------------------------------------------------------
  dut: entity work.carry_save_adder
    generic map(
      SIZE     => SIZE)
    port map (
      csa_in   => signal_csa_in,
      csa_sum  => signal_csa_sum,
      csa_cout => signal_csa_cout);

  -------------------------------------------------------------------------------
  -- stimulus
  -------------------------------------------------------------------------------
  stimulus: process
    variable var_csa_in : slv_vector(0 to 2)(SIZE-1 downto 0);
    variable var_csa_sum: std_logic_vector(SIZE-1 downto 0);
    variable var_csa_cout: std_logic_vector(SIZE-1 downto 0);
  begin
    print("** Testing carry_save_adder");

    -- Validate all possible input combinations
    for ii in 0 to SIZE**2-1 loop
      for jj in 0 to SIZE**2-1 loop
        for kk in 0 to SIZE**2-1 loop
          var_csa_in(0) := std_logic_vector(to_unsigned(ii, SIZE));
          var_csa_in(1) := std_logic_vector(to_unsigned(jj, SIZE));
          var_csa_in(2) := std_logic_vector(to_unsigned(kk, SIZE));

          signal_csa_in <= var_csa_in;

          wait for PERIOD;

          -- Generate expected sum and cout
          var_csa_sum  := (var_csa_in(0) xor var_csa_in(1) xor var_csa_in(2));
          var_csa_cout := (var_csa_in(0) and var_csa_in(1)) or (var_csa_in(1) and var_csa_in(2)) or (var_csa_in(0) and var_csa_in(2));

          -- Verify sum and cout
          assert signal_csa_sum  = var_csa_sum
            report "Error: Incorrect sum. Actual "& to_string(signal_csa_sum) &". Expected "& to_string(var_csa_sum)
            severity FAILURE;

          assert signal_csa_cout = var_csa_cout
            report "Error: Incorrect carry out. Actual "& to_string(signal_csa_cout) &". Expected "& to_string(var_csa_cout)
            severity FAILURE;
        end loop;
      end loop;
    end loop;

    wait for PERIOD;
    print("** FINISHED carry_save_adder test");
    finish;
  end process;
end architecture behavior;
