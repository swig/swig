
if [ catch { load ./primitive_types[info sharedlibextension] Primitive_types} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}


if {[val_int 10] != 10 }  { error "bad int map"  }
if {[val_schar 10] != 10 } { error "bad char map" }
if {[val_short 10] != 10 } { error "bad schar map" }


if [catch { val_schar 10000 } ] {} else { error "bad schar map" }
if [catch { val_uint  -100 } ]  {} else { error "bad uint map"  }
if [catch { val_uchar -100 } ]  {} else { error "bad uchar map" }
if [catch { val_ulong " -1" } ] {} else { error "bad ulong map" }
if [catch { val_ullong -1 } ]   {} else { error "bad ullong map" }
if [catch { val_ullong " -1" } ] {} else { error "bad ullong map" }
if {[val_ullong 18446744073709551615] != 18446744073709551615 } { error "bad ullong map" }
if {$tcl_platform(wordSize) == 8} {
  if {[val_ulong "18446744073709551615 "] != 18446744073709551615 } { error "bad ulong map" }
  if {[val_ullong "18446744073709551615 "] != 18446744073709551615 } { error "bad ullong map" }
}

if {[val_uint 10] != 10 }  { error "bad uint map"  }
if {[val_uchar 10] != 10 } { error "bad uchar map" }
if {[val_ushort 10] != 10 } { error "bad ushort map" }


if {[val_double 10] != 10 } { error "bad double map" }
if {[val_float 10] != 10 } { error "bad double map" }



if [catch { val_float hello } ] {} else { error "bad double map" }

if {[val_char c] != "c" } { error "bad char map" }
if {[val_char "c"] != "c" } { error "bad char map" }
if {[val_char 101] != "e" } { error "bad char map" }



