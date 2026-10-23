if [ catch { load ./li_typemaps[info sharedlibextension] Li_typemaps} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}

proc check_equal {actual expected what} {
	if { $actual != $expected } {
		error "$what returned $actual, expected $expected"
	}
}

check_equal [ in_int 7 ] 7 "in_int"
check_equal [ inr_int 7 ] 7 "inr_int"
check_equal [ out_int 7 ] 7 "out_int"
check_equal [ inout_int 7 ] 7 "inout_int"
check_equal [ inoutr_int 7 ] 7 "inoutr_int"

# Two parameters using the same typemap
check_equal [ in_int_multi 3 4 ] 7 "in_int_multi"
check_equal [ out_int_multi 5 6 ] {5 6} "out_int_multi"
check_equal [ inout_int_multi 7 8 ] {14 24} "inout_int_multi"

# A reference cannot be bound to a null pointer, so NULL is rejected rather than dereferenced in the call
proc check_nullref_rejected {fn} {
	if { [ catch { $fn NULL } err_msg ] != 1 } {
		error "'$fn' accepted NULL for a reference"
	}
}

proc inr {val} { inr_int $val }
proc inoutr {val} { inoutr_int $val }
check_nullref_rejected inr
check_nullref_rejected inoutr
