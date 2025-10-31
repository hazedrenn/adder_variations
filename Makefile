# This is called a canned recipe. Similar to what a function would do
blank :=
define newline

$(blank)
endef

# Allows a preview of a README.md file
readme: README.md
	pandoc --from gfm --to html README.md > README.html
	firefox README.html

MODULES												:=full_adder half_adder carry_look_ahead_adder carry_skip_adder carry_save_adder
GHDL_SCRIPT										:=scripts/signals.tcl
PACKAGES											:=sim/sim_io_package.vhd
full_adder_SOURCES						:=src/full_adder.vhd
half_adder_SOURCES						:=src/half_adder.vhd
carry_skip_adder_SOURCES			:=src/half_adder.vhd
carry_save_adder_SOURCES			:=src/half_adder.vhd src/full_adder.vhd
carry_look_ahead_adder_SOURCES:=src/carry_look_ahead_adder.vhd

# Individual simulation runs of each module
$(MODULES): $(GHDL_SCRIPT)
	$(foreach file, $(PACKAGES) $($@_SOURCES) sim/$@_tb.vhd, ghdl -a --std=08 $(file) $(newline))
	ghdl -e --std=08 $@_tb
	ghdl -r --std=08 $@_tb --wave=wave/$@_tb.ghw
	gtkwave wave/$@_tb.ghw --script=$(GHDL_SCRIPT)

.PHONY: all clean

# run all
all: $(MODULES)

# Cleans up files that aren't source files
clean:
	-rm *.cf
	-rm *.html
