load ./debug[info sharedlibextension]

proc death_by_segmentation { } {
    seg_crash
}

proc death_by_bus { } {
    bus_crash
}

proc death_by_abort { } {
    abort_crash -1
}

proc death_by_math { } {
    math_crash 37 0
}

proc death_by_buffer { } {
    overflow_crash
}

set method 1
proc death {} {
    global method
    if { $method == 1 } {
        death_by_segmentation
    }
    if { $method == 2 } {
        death_by_abort
    }
    if { $method == 3 } {
        death_by_math
    }
    if { $method == 4 } {
        death_by_bus
    }
    if { $method == 5 } {
        death_by_buffer
    }
}

label .l -text "How would you like to die today?"
pack .l

radiobutton .r1 -text "Segmentation fault" -variable method -value 1
pack .r1 -anchor w

radiobutton .r2 -text "Failed assertion" -variable method -value 2
pack .r2 -anchor w

radiobutton .r3 -text "Math error" -variable method -value 3
pack .r3 -anchor w

radiobutton .r4 -text "Bus error" -variable method -value 4
pack .r4 -anchor w

radiobutton .r5 -text "Stack overflow" -variable method -value 5
pack .r5 -anchor w 

button .b -text "Die" -command death 
pack .b -fill both -expand 1

wm title . "Death Wizard"

