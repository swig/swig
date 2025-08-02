
if [ catch { load ./inout_typemaps[info sharedlibextension] Inout_typemaps} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}


if {[AddOne1 10] != 11} { error "fail AddOne1" }

set a [AddOne3 10 20 30]
if {[lindex $a 0] != 11} { error "fail AddOne3[0]" }
if {[lindex $a 1] != 21} { error "fail AddOne3[1]" }
if {[lindex $a 2] != 31} { error "fail AddOne3[2]" }

if {[AddOne1r 20] != 21} { error "fail AddOner" }

set a [NonVoidOut -42]
if {[lindex $a 0] != "NULL"} { error "fail NonVoidOut[0]" }
if {[lindex $a 1] != 0} { error "fail NonVoidOut[1]" }
