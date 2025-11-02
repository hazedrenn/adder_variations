library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;
use std.textio.all;

package sim_io_package is
  -- procedure print
  procedure print(s: string);
end package sim_io_package;

package body sim_io_package is
  -- procedure print
  procedure print(s: string) is
    variable l: line;
  begin
    write(l, s);
    writeline(output, l);
  end procedure print;
end package body sim_io_package;
