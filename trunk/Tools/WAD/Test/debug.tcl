# WAD debugging module for Tcl.  This should be executed with wish

load ./debug[info sharedlibextension]

message .t -text "This program tests various program faults. Note: Not all of these errors can be gracefully handled."

button .b1 -text "Segmentation fault" -command "seg_crash" 
button .b2 -text "Bus error (not on Linux)" -command "bus_crash"
button .b3 -text "Abort" -command "abort_crash -1"
button .b4 -text "Math" -command "math_crash 3 0"
button .b5 -text "Blow Heap" -command "blowheap_crash"
button .b6 -text "Buffer overflow" -command "overflow_crash"
button .q -text "Quit" -command "exit"

pack .t -fill x

pack .b1 -fill x
pack .b2 -fill x
pack .b3 -fill x
pack .b4 -fill x
pack .b5 -fill x
pack .b6 -fill x
pack .q -fill x


