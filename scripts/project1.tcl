#!usr/bin/tclsh
# Run this script in the /scripts folder

set PROJECT_NAME "project1"
set BUILD_PATH "../build"
set SOURCE_PATH "../src"
set SIM_PATH "../sim"
set BOARD "xc7vx485tffg1157-1"

create_project -force $PROJECT_NAME $BUILD_PATH/$PROJECT_NAME -part $BOARD


set source_files [exec ls $SOURCE_PATH]
foreach source_file $source_files {
  add_files -fileset sources_1 $SOURCE_PATH/$source_file;
  set_property FILE_TYPE {VHDL 2008} [get_files $SOURCE_PATH/$source_file]
}
update_compile_order -fileset sources_1


set sim_files [exec ls $SIM_PATH]
foreach sim_file $sim_files {
  add_files -fileset sim_1 $SIM_PATH/$sim_file;
  set_property FILE_TYPE {VHDL 2008} [get_files $SIM_PATH/$sim_file]
}
update_compile_order -fileset sim_1

# run simulation for full_adder
set_property top full_adder_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1

launch_simulation
close_sim

# run simulation for adder
set_property top adder_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1

launch_simulation
close_sim

# run simulation for half_adder
set_property top half_adder_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1

launch_simulation
close_sim
