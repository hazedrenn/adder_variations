# This is called a canned recipe. Similar to what a function would do
define run_ghdl =
	ghdl -a --std=08 $(PACKAGES)
	ghdl -a --std=08 sim/$@_tb.vhd
	ghdl -a --std=08 src/$@.vhd
	ghdl -e --std=08 $@_tb
	ghdl -r --std=08 $@_tb --wave=wave/$@_tb.ghw
	gtkwave wave/$@_tb.ghw --script=$(GHDL_SCRIPT)
endef

# Allows a preview of a README.md file
readme: README.md
	pandoc --from gfm --to html README.md > README.html
	firefox README.html

GHDL_SCRIPT:=scripts/signals.tcl
PACKAGES:=sim/sim_io_package.vhd

# Individual simulation runs of each module
full_adder: $(PACKAGES) $(GHDL_SCRIPT) sim/full_adder_tb.vhd src/full_adder.vhd 
	$(run_ghdl)

half_adder: $(PACKAGES) $(GHDL_SCRIPT) sim/half_adder_tb.vhd src/half_adder.vhd
	$(run_ghdl)

carry_save_adder: $(PACKAGES) $(GHDL_SCRIPT) sim/carry_save_adder_tb.vhd src/carry_save_adder.vhd
	$(run_ghdl)

# Cleans up files that aren't source files
.PHONY: clean
clean:
	-rm *.cf
	-rm *.html
