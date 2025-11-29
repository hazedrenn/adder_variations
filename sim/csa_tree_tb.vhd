-------------------------------------------------------------------------------
-- csa_tree_tb
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.finish;
use std.textio.all;

library work;
use work.sim_io_package.all;
use work.general_package.all;
use work.csa_package.all;

-------------------------------------------------------------------------------
-- entity
-------------------------------------------------------------------------------
entity csa_tree_tb is
  generic ( TEST_CASE : natural := 10 );
end entity csa_tree_tb;

-------------------------------------------------------------------------------
-- architecture
-------------------------------------------------------------------------------
architecture behavior of csa_tree_tb is
  type InputModeType is (INCREMENT, RANDOM, DECREMENT, FILLED);

  type TestSettingsType is record 
    NumberOfInputs : positive;
    SizeOfInputs : positive;
    InputMode: InputModeType;
  end record TestSettingsType;

  type TestSettingsArray is array (natural range<>) of TestSettingsType;
  --                                                            W x  L  InputMode
  constant TestSettings : TestSettingsArray(0 to 19) := ( 0 => ( 3,  4, INCREMENT),
                                                          1 => ( 4,  4, INCREMENT),
                                                          2 => ( 5,  4, INCREMENT),
                                                          3 => ( 6,  4, INCREMENT),
                                                          4 => ( 7,  4, INCREMENT),
                                                          5 => ( 8,  4, INCREMENT),
                                                          6 => ( 9,  4, INCREMENT),
                                                          7 => (10,  4, INCREMENT),
                                                          8 => (11,  4, INCREMENT),
                                                          9 => (11, 11, INCREMENT),
                                                         10 => ( 8,  4,    RANDOM),
                                                         11 => ( 8,  4, DECREMENT),
                                                         12 => ( 8,  4,    FILLED),
                                                     others => ( 2,  2, INCREMENT));  
  -------------------------------------------------------------------------------
  -- constants
  -------------------------------------------------------------------------------
  constant NUM_OF_INPUTS  : positive      := TestSettings(TEST_CASE).NumberOfInputs;
  constant SIZE_OF_INPUTS : positive      := TestSettings(TEST_CASE).SizeOfInputs;
  constant INPUT_MODE     : InputModeType := TestSettings(TEST_CASE).InputMode;
  constant MAX_HEIGHT     : natural       := csa_tree_height(NUM_OF_INPUTS);
  constant DEBUG          : boolean       := FALSE;
  constant PERIOD         : time          := 1 ns;

  -------------------------------------------------------------------------------
  -- signals
  -------------------------------------------------------------------------------
  signal signal_inputs    : slv_vector(0 to NUM_OF_INPUTS-1)(SIZE_OF_INPUTS-1 downto 0);
  signal csa_enable       : slvv_vector(MAX_HEIGHT downto 0)(0 to NUM_OF_INPUTS-1)(clog2(NUM_OF_INPUTS)+SIZE_OF_INPUTS-1 downto 0) := generate_csa_enable(NUM_OF_INPUTS, SIZE_OF_INPUTS, MAX_HEIGHT);
  signal csa_row          : integer_3vector(MAX_HEIGHT downto 0)(0 to NUM_OF_INPUTS-1)(clog2(NUM_OF_INPUTS)+SIZE_OF_INPUTS-1 downto 0) := generate_csa_reroute_row(NUM_OF_INPUTS, SIZE_OF_INPUTS, MAX_HEIGHT);
  signal csa_col          : integer_3vector(MAX_HEIGHT downto 0)(0 to NUM_OF_INPUTS-1)(clog2(NUM_OF_INPUTS)+SIZE_OF_INPUTS-1 downto 0) := generate_csa_reroute_col(NUM_OF_INPUTS, SIZE_OF_INPUTS, MAX_HEIGHT);
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
    variable output_line   : line;
    variable seed1, seed2  : integer := 314;
    variable RandVar       : real;
  begin
    print("** Testing csa_tree Test #"& integer'image(TEST_CASE));
    print("Height is "& integer'image(csa_tree_height(NUM_OF_INPUTS)));
    print("Number of inputs is "& integer'image(NUM_OF_INPUTS));
    print("Input mode is "& InputModeType'image(INPUT_MODE));

    if DEBUG = TRUE then
      for h in csa_enable'length-1 downto 0 loop
        for row in 0 to csa_enable(h)'length-1 loop
          print(to_string(csa_enable(h)(row)));
        end loop;
        print(" ");
        for row in 0 to csa_enable(h)'length-1 loop
          for col in csa_enable(h)(row)'length-1 downto 0 loop
            write(output_line, "("&integer'image(csa_row(h)(row)(col))&", "&integer'image(csa_col(h)(row)(col))&") ");
          end loop;
          writeline(output, output_line);
        end loop;
        print(" ");
      end loop;
    end if;

    for i in 0 to signal_inputs'length-1 loop
      if INPUT_MODE = INCREMENT then
        InputVar        := std_logic_vector(to_unsigned(i, SIZE_OF_INPUTS));
      elsif INPUT_MODE = RANDOM then
        uniform(seed1, seed2, RandVar);
        InputVar        := std_logic_vector(to_unsigned(integer(RandVar * real(SIZE_OF_INPUTS**2-1)), SIZE_OF_INPUTS));
      elsif INPUT_MODE = DECREMENT then
        InputVar        := std_logic_vector(to_unsigned(SIZE_OF_INPUTS**2-1-i, SIZE_OF_INPUTS));
      else -- INPUT_MODE = FILLED then
        InputVar        := (others => '1');
      end if;
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

    -- Validate Sum
    assert ExpectedSumVar = to_integer(unsigned(signal_sum))
      report "Unexpected Sum, expected " & integer'image(ExpectedSumVar)
      severity failure;

    print("** csa_tree test PASSED");
    wait for PERIOD;
    finish;
  end process;
end architecture behavior;
