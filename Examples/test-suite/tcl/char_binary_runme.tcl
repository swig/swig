
if [ catch { load ./char_binary[info sharedlibextension] Char_binary} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}

Test t
set str "hile"
if { [ t strlen $str ] != 4 } {
   puts stderr "bad multi-arg typemap"
   exit 1
}
if { [ t ustrlen $str ] != 4 } {
   puts stderr "bad multi-arg typemap"
   exit 1
}

# The universal character Escape Sequence is 2 bytes
set str2 "hi\u0000"
if { [ t strlen $str2 ] != 4 } {
   puts stderr "bad multi-arg typemap"
   exit 1
}
if { [ t ustrlen $str2 ] != 4 } {
   puts stderr "bad multi-arg typemap"
   exit 1
}

# creating a raw char*
set pc [ new_pchar 5 ]
pchar_setitem $pc 0 h
pchar_setitem $pc 1 o
pchar_setitem $pc 2 l
pchar_setitem $pc 3 a
pchar_setitem $pc 4 0

# FIXME: pc is not a string in tcl
if { 0 } {
   if { [ t strlen $pc ] != 4 } {
      puts stderr "bad multi-arg typemap"
      exit 1
   }
   if { [ t ustrlen $pc ] != 4 } {
      puts stderr "bad multi-arg typemap"
      exit 1
   }
}

# FIXME: pc is not a string in tcl
if { 0 } {
   set var_pchar $pc
} else {
   set var_pchar "hola"
}
if { $var_pchar != "hola" } {
   puts stderr "bad pointer case"
   exit 1
}

# FIXME: pc is not a string in tcl
if { 0 } {
   set var_namet $pc
} else {
   set var_namet "hola"
}
if { $var_namet != "hola" } {
   puts stderr "bad pointer case"
   exit 1
}

delete_pchar $pc
