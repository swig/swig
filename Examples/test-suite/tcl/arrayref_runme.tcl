if [ catch { load ./arrayref[info sharedlibextension] Arrayref} err ] {
    puts stderr "Could not load shared object:\n$err"
    exit 1
}

# Setting a variable that is a reference to an array copies into the array it refers to.
if {[numbers_sum] != 10} { error "numbers_sum" }
set numbers_ref $others
if {[numbers_sum] != 100} { error "numbers_sum after set" }

# An array of char is a string here, and so is a reference to one.
if {$letters != "abc"} { error "letters" }
if {$letters_ref != "abc"} { error "letters_ref" }
set letters_ref "xy"
if {[letters_are] != "xy"} { error "letters_are" }
if {$frozen_ref != "xyz"} { error "frozen_ref" }

ArrayRefMember member
if {[member sum] != 10} { error "member sum" }
if {[member cget -text_ref] != "hi"} { error "member text_ref" }
member configure -text_ref "bye"
if {[member text_is] != "bye"} { error "member text_is" }

# Setting a reference to an array of arrays copies every element.
set grid_ref $other_grid
if {[grid_element 0 1] != 20} { error "grid_element 0 1" }
if {[grid_element 1 2] != 60} { error "grid_element 1 2" }

GridRefMember grid_member
grid_member configure -rows_ref [other_grid_address]
if {[grid_member element 0 1] != 20} { error "grid member element 0 1" }
if {[grid_member element 1 2] != 60} { error "grid member element 1 2" }
