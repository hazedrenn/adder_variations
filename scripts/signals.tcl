set faclist     [ list ]
set signal_list [ list ]
set nfacs       [ gtkwave::getNumFacs ]
set entity_dict [ dict create ]


# Create list of raw signals containing the heirarchy path and signal name
set remove_bracket_data {\[.+?\]}
for {set i 0} {$i < $nfacs} {incr i} {
  set facname [ gtkwave::getFacName $i ]
  lappend faclist $facname
}

foreach fac $faclist {
  puts $fac
}

# faclist format: 
#  top.module_tb.module.signal_a[0]
#  top.module_tb.module.signal_a[1]
#  top.module_tb.module.signal_b[0]
#  top.module_tb.module.signal_b[1]
#  top.module_tb.module.signal_c

#set signal_list $faclist

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

# writelist format: 
#  top.module_tb.module.signal_a
#  top.module_tb.module.signal_b
#  top.module_tb.module.signal_c
# readlist format: 
#  top.module_tb.module.signal_a[1:0]
#  top.module_tb.module.signal_b[1:0]
#  top.module_tb.module.signal_c

# Add signals to list
gtkwave::addSignalsFromList $signal_write_list

# Create a dictionary of enitities mapped to their signal list
foreach signal $signal_read_list {
  # Extract the entity name of the signal
  set split_signal [ split $signal "." ]
  set entity       [ lindex $split_signal end-1 ]

  # Add signal to the signal list of the entity
  dict lappend entity_dict $entity $signal
}

# Group signals by their entity name
dict for {entity signal_list} $entity_dict {
  puts $entity
  puts "putsputs"
  foreach signal $signal_list {
    puts "\t$signal"
  }
  gtkwave::highlightSignalsFromList $signal_list
  if {$entity == "full_adder_tb"} {
    break
  }
  gtkwave::/Edit/Create_Group       $entity
  gtkwave::unhighlightSignalsFromList $signal_list
  break
}

# Zoom out completely
gtkwave::/Time/Zoom/Zoom_Full
