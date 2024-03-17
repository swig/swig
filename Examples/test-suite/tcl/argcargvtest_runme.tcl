if [ catch { load ./argcargvtest[info sharedlibextension] Argcargvtest} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}

set largs {hi hola hello}
if {[mainc $largs] != 3} {
     puts stderr "bad main typemap"
     exit 1
}

set targs {hi hola}
if {[mainv $targs 0] != "hi"} {
     puts stderr "bad main typemap"
     exit 1
}
if {[mainv $targs 1] != "hola"} {
     puts stderr "bad main typemap"
     exit 1
}
if {[mainv $targs 2] != "<<NULL>>"} {
     puts stderr "bad main typemap"
     exit 1
}

set targs " hi hola "
if {[mainv $targs 0] != "hi"} {
     puts stderr "bad main typemap"
     exit 1
}
if {[mainv $targs 1] != "hola"} {
     puts stderr "bad main typemap"
     exit 1
}

if { ! [ catch { mainv("hello", 1) } ] } {
    puts stderr "bad main typemap"
    exit 1
}

initializeApp $largs

# Check that an empty array works.
set empty_args {}
if {[mainc $empty_args] != 0} {
    puts stderr "bad main typemap"
    exit 1
}
if {[mainv $empty_args 0] != "<<NULL>>"} {
     puts stderr "bad main typemap"
     exit 1
}

# Check that empty strings are handled.
set empty_string {"hello" "" "world"}
if {[mainc $empty_string] != 3} {
    puts stderr "bad main typemap"
    exit 1
}
if {[mainv $empty_string 0] != "hello"} {
    puts stderr "bad main typemap"
    exit 1
}
if {[mainv $empty_string 1] != ""} {
    puts stderr "bad main typemap"
    exit 1
}
if {[mainv $empty_string 2] != "world"} {
    puts stderr "bad main typemap"
    exit 1
}
if {[mainv $empty_string 3] != "<<NULL>>"} {
    puts stderr "bad main typemap"
    exit 1
}
