# VHDL Adder Variations

Adder Variations is a library of modules that contain different architectures for adders. Adders can be configured differently in hardware to trade off area for propagation time and vice versa. Below is a list of the modules:

* half adder
* full adder
* carry skip adder
* carry look ahead adder
* carry save adder
* n-bit full adder
* carry skip adder


A makefile is included to simplify compilation runs for each and every module. The makefile script uses GHDL for VHDL compilation and simulation. GTKWave is used to view waveforms for each simulation. Tcl scripts are used to quickly add signals to the waveform for a more streamlined waveform debugging process.
