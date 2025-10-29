#!usr/bin/tclsh
#
# Creates a Module Tree given a list of signals
# This must account for module vectors, signal vectors, and multidimensional signals
#
# This script should have a function that returns a dict of a nested hieracry of 
# modules as well as a print function to visually observe the module tree.
#
# for example:
#
# signal_list =
# top.module_tb.dut.output
# top.module_tb.tb_sig[0]
# top.module_tb.tb_sig[1]
# top.module_tb.tb_sig[2]
# top.module_tb.module.sig_a[0]
# top.module_tb.module.sig_a[1]
# top.module_tb.module.sig_a[2]
# top.module_tb.module.sig_a[3]
# top.module_tb.module.sig_b
# top.module_tb.module.generate[0].fa.a
# top.module_tb.module.generate[1].fa.a
# top.module_tb.module.generate[2].fa.a
#
# The print funciton of the module tree would look like this:
#
# top 
# ├── module_tb
# │   └── dut  
# │       └── output
# ├── tb_sig[2:0]
# └── module
#     ├── sig_a[3:0]
#     ├── sig_b
#     └── generate[2:0]
#         └── fa
#             └── a
#
#

proc create_module_tree {signal_list} {
  puts "Created module tree."
}
proc print_module_tree {module_tree_dict} {
  puts "Printed module tree."
}
set prev_name [ regsub -all $remove_bracket_data [ lindex $faclist 0 ] "" ]
set num_list  [ list ]
set signal_write_list [ list ]
set signal_read_list [ list ]
set range ""
set extract_bracket_number {[0-9]+?(?=\])}

foreach signal $faclist {
  set name [regsub -all $remove_bracket_data $signal ""] 
  set num [regexp -inline $extract_bracket_number $signal]

  if {$prev_name == $name} {
    lappend num_list $num
  } else {
    # Save num_list as a range
    if {[llength $num_list] > 1} {
      set range "\[[lindex $num_list end]:[lindex $num_list 0]\]"
    } else {
      set range ""
    }   

    # Append new name to name_list
    lappend signal_write_list $prev_name
    lappend signal_read_list "$prev_name$range"
    puts "write: $prev_name read: $prev_name$range numbers: $num_list"
        
    # Update prev_name
    set prev_name $name

    # Make new num_list
    set num_list [list $num]
  }
}

# Process last name
if {[llength $num_list] > 1} {
  set range "\[[lindex $num_list end]:[lindex $num_list 0]\]"
} else {
  set range ""
}

lappend signal_write_list $prev_name
lappend signal_read_list "$prev_name$range"
puts "write: $prev_name read: $prev_name$range"

