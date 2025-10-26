clean:
	rm *.cf
half_adder: sim/my_package.vhd sim/half_adder_tb.vhd src/half_adder.vhd scripts/signals.tcl
	ghdl -a --std=08 sim/my_package.vhd
	ghdl -a --std=08 sim/half_adder_tb.vhd
	ghdl -a --std=08 src/half_adder.vhd
	ghdl -e --std=08 half_adder_tb
	ghdl -r --std=08 half_adder_tb --wave=wave/half_adder_tb.ghw
	gtkwave wave/half_adder_tb.ghw --script=scripts/signals.tcl
full_adder: sim/my_package.vhd sim/full_adder_tb.vhd src/full_adder.vhd scripts/signals.tcl
	ghdl -a --std=08 sim/my_package.vhd
	ghdl -a --std=08 sim/full_adder_tb.vhd
	ghdl -a --std=08 src/full_adder.vhd
	ghdl -e --std=08 full_adder_tb
	ghdl -r --std=08 full_adder_tb --wave=wave/full_adder_tb.ghw
	gtkwave wave/full_adder_tb.ghw --script=scripts/signals.tcl
r4_csa_adder: sim/my_package.vhd sim/r4_csa_adder_tb.vhd src/r4_csa_adder.vhd scripts/signals.tcl
	ghdl -a --std=08 sim/my_package.vhd
	ghdl -a --std=08 sim/r4_csa_adder_tb.vhd
	ghdl -a --std=08 src/r4_csa_adder.vhd
	ghdl -e --std=08 r4_csa_adder_tb
	ghdl -r --std=08 r4_csa_adder_tb --wave=wave/r4_csa_adder_tb.ghw 
	gtkwave wave/r4_csa_adder_tb.ghw --script=scripts/signals.tcl
