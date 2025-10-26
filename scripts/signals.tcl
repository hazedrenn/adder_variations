set faclist [list]

set nfacs [ gtkwave::getNumFacs ]

set entity_dict [dict create]

# Create list of raw signals containing the heirarchy path and signal name
for {set i 0} {$i < $nfacs} {incr i} {
  set facname [ gtkwave::getFacName $i ]
  lappend faclist "$facname"
}

# Create a dictionary of enitities mapped to their signal list
foreach facname $faclist {
  # Extract the entity name of the signal
  set split_signal [split $facname, "."]
  set entity [lindex $split_signal end-1]

  # Add signal to the signal list of the entity
  dict lappend entity_dict $entity $facname
}

# Group signals by their entity name
dict for {entity signal_list} $entity_dict {
  gtkwave::addSignalsFromList $signal_list
  gtkwave::highlightSignalsFromList $signal_list
  gtkwave::/Edit/Create_Group $entity
}

# Zoom out completely
gtkwave::/Time/Zoom/Zoom_Full
