# This is called a canned recipe. Similar to what a function would do
blank :=
define newline

$(blank)
endef

# Allows a preview of a README.md file
readme: README.md
	pandoc --from gfm --to html README.md > README.html
	firefox README.html

MODULES												 :=full_adder half_adder carry_look_ahead_adder carry_skip_adder carry_save_adder n_bit_full_adder carry_select_adder csa_tree_level slice csa_tree_results csa_tree_pipelined
GHDL_SCRIPT										 :=scripts/signals.tcl
PACKAGES											 :=sim/sim_io_package.vhd src/general_package.vhd src/csa_package.vhd
full_adder_SOURCES						 :=src/full_adder.vhd
half_adder_SOURCES						 :=src/half_adder.vhd
carry_skip_adder_SOURCES			 :=src/full_adder.vhd src/carry_skip_adder.vhd
carry_save_adder_SOURCES			 :=src/full_adder.vhd src/carry_save_adder.vhd
carry_look_ahead_adder_SOURCES :=src/carry_look_ahead_adder.vhd
n_bit_full_adder_SOURCES			 :=src/full_adder.vhd src/n_bit_full_adder.vhd
carry_select_adder_SOURCES		 :=src/full_adder.vhd src/n_bit_full_adder.vhd src/carry_select_adder.vhd
csa_tree_level_SOURCES			   :=src/full_adder.vhd src/carry_save_adder.vhd src/csa_tree_level.vhd
csa_tree_SOURCES			   			 :=src/half_adder.vhd src/full_adder.vhd src/n_bit_full_adder.vhd src/carry_save_adder.vhd src/csa_tree.vhd
csa_tree_pipelined_SOURCES		 :=src/half_adder.vhd src/full_adder.vhd src/n_bit_full_adder.vhd src/carry_save_adder.vhd src/csa_tree_pipelined.vhd
slice_SOURCES			   			     :=src/slice.vhd
csa_tree_results_SOURCES			 :=src/csa_tree_results.vhd

# Individual simulation runs of each module
csa_tree: $(GHDL_SCRIPT) $(PACKAGES)
	$(foreach file, $(PACKAGES) $($@_SOURCES) sim/$@_tb.vhd, ghdl -a --std=08 $(file) $(newline))
	ghdl -e --std=08 $@_tb
	ghdl -r --std=08 $@_tb -gTEST_CASE=0 --wave=wave/$@_tb.ghw
	gtkwave wave/$@_tb.ghw 
	#ghdl -r --std=08 $@_tb -gTEST_CASE=1 --wave=wave/$@_tb.ghw
	#gtkwave wave/$@_tb.ghw 
	#ghdl -r --std=08 $@_tb -gTEST_CASE=2 --wave=wave/$@_tb.ghw
	#gtkwave wave/$@_tb.ghw 

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
