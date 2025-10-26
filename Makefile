# This is called a canned recipe. Similar to what a function would do
define run_ghdl =
	ghdl -a --std=08 sim/my_package.vhd
	ghdl -a --std=08 sim/$@_tb.vhd
	ghdl -a --std=08 src/$@.vhd
	ghdl -e --std=08 $@_tb
	ghdl -r --std=08 $@_tb --wave=wave/$@_tb.ghw
	gtkwave wave/$@_tb.ghw --script=scripts/signals.tcl
endef

# Allows a preview of a README.md file
readme: README.md
	pandoc --from gfm --to html README.md > README.html
	firefox README.html

# Individual simulation runs of each module
full_adder: sim/my_package.vhd sim/full_adder_tb.vhd src/full_adder.vhd scripts/signals.tcl
	$(run_ghdl)

half_adder: sim/my_package.vhd sim/half_adder_tb.vhd src/half_adder.vhd scripts/signals.tcl
	$(run_ghdl)

r4_csa_adder: sim/my_package.vhd sim/r4_csa_adder_tb.vhd src/r4_csa_adder.vhd scripts/signals.tcl
	$(run_ghdl)

# Cleans up files that aren't source files
.PHONY: clean
clean:
	-rm *.cf
	-rm *.html
