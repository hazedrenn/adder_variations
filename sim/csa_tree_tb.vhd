-------------------------------------------------------------------------------
-- csa_tree_tb
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
entity csa_tree_tb is
  generic ( TEST_CASE : natural := 0 );
end entity csa_tree_tb;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture behavior of csa_tree_tb is
  type TestSettingsType is record 
    NumberOfInputs : positive;
    LengthOfInputs : positive;
  end record TestSettingsType;
  type TestSettingsArray is array (natural range<>) of TestSettingsType;
  --                                                            W x L
  constant TestSettings : TestSettingsArray(0 to 19) := ( 0 => ( 3, 4),
                                                          1 => ( 4, 4),
                                                          2 => ( 5, 4),
                                                     others => ( 2, 2) );  
  -------------------------------------------------------------------------------
  -- constants
  -------------------------------------------------------------------------------
  constant NUM_OF_INPUTS  : positive :=  TestSettings(TEST_CASE).NumberOfInputs;
  constant SIZE_OF_INPUTS : positive :=  TestSettings(TEST_CASE).LengthOfInputs;
  constant PERIOD         : time := 1 ns;

  -------------------------------------------------------------------------------
  -- signals
  -------------------------------------------------------------------------------
  signal signal_inputs    : slv_vector(0 to NUM_OF_INPUTS-1)(SIZE_OF_INPUTS-1 downto 0);
  signal signal_cout      : std_logic;
  signal signal_sum       : std_logic_vector(SIZE_OF_INPUTS+clog2(NUM_OF_INPUTS)-1 downto 0);
begin
  -------------------------------------------------------------------------------
  -- dut
  -------------------------------------------------------------------------------
  dut: entity work.csa_tree
  generic map( 
    NUM_OF_INPUTS  => NUM_OF_INPUTS,
    SIZE_OF_INPUTS => SIZE_OF_INPUTS)
  port map (
    inputs         => signal_inputs,
    cout           => signal_cout,
    sum            => signal_sum);

  -------------------------------------------------------------------------------
  -- stimulus
  -------------------------------------------------------------------------------
  stimulus: process
    variable ExpectedSumVar: integer := 0;
    variable InputVar      : std_logic_vector(SIZE_OF_INPUTS-1 downto 0);
    variable InputMatrixVar: slv_vector(0 to NUM_OF_INPUTS-1)(SIZE_OF_INPUTS-1 downto 0);
    constant TestSLVVar    : std_logic_vector(SIZE_OF_INPUTS-1 downto 0) := "0100";
  begin
    print("** Testing csa_tree Test #"& integer'image(TEST_CASE));
    print("Height is "& integer'image(csa_tree_height(NUM_OF_INPUTS)));
    print("Number of inputs is "& integer'image(NUM_OF_INPUTS));

    for i in 0 to signal_inputs'length-1 loop
      InputVar          := std_logic_vector(to_unsigned(SIZE_OF_INPUTS**2-1-i, SIZE_OF_INPUTS));
      InputMatrixVar(i) := InputVar;
      ExpectedSumVar    := ExpectedSumVar + to_integer(unsigned(InputVar));
    end loop;

    signal_inputs <= InputMatrixVar;
    wait for PERIOD;

    for i in 0 to signal_inputs'length-1 loop
      print("  "&to_string(signal_inputs(i)));
    end loop;

    print("  ----");
    print(to_string(signal_sum));
    wait for PERIOD;

    assert ExpectedSumVar = to_integer(unsigned(signal_sum))
      report "Unexpected Sum, expected " & integer'image(ExpectedSumVar)
      severity WARNING;

    print("** csa_tree test PASSED");
    wait for PERIOD;
    finish;
  end process;
end architecture behavior;
