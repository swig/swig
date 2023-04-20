if [ catch { load ./argcargvtest[info sharedlibextension] argcargvtest} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}

set largs {hi hola hello}
if {[mainc $largs] != 3} {
     puts stderr "bad main typemap"
     exit 1
}

set targs {hi hola}
if {[mainv $targs 1] != "hola"} {
     puts stderr "bad main typemap"
     exit 1
}

set targs " hi hola "
if {[mainv $targs 1] != "hola"} {
     puts stderr "bad main typemap"
     exit 1
}

if { ! [ catch { mainv("hello", 1) } ] } {
    puts stderr "bad main typemap"
    exit 1
}

initializeApp $largs
