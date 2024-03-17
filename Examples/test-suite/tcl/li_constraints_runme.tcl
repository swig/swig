if [ catch { load ./li_constraints[info sharedlibextension] Li_constraints} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}

proc check_double {except fn f val} {
	set actual [ catch { $fn $val } err_msg ]
	if { $actual == 0 } {
		if { $except != 0 } {
			error "function '$f' with $val should perform an exception"
		}
	} else {
		if { $except == 0 } {
			error "function '$f' with $val should not perform an exception"
		} elseif { [ string equal $err_msg "ValueError Expected a $f value." ] != 1 } {
			error "function '$f' with $val should perform a proper exception"
		}
	}
}

proc nonnegative {val } { test_nonnegative $val }
check_double 0 nonnegative "non-negative" 10
check_double 0 nonnegative "non-negative" 0
check_double 1 nonnegative "non-negative" -10

proc nonpositive {val } { test_nonpositive $val }
check_double 1 nonpositive "non-positive" 10
check_double 0 nonpositive "non-positive" 0
check_double 0 nonpositive "non-positive" -10

proc positive {val } { test_positive $val }
check_double 0 positive "positive" 10
check_double 1 positive "positive" 0
check_double 1 positive "positive" -10

proc negative {val } { test_negative $val }
check_double 1 negative "negative" 10
check_double 1 negative "negative" 0
check_double 0 negative "negative" -10

proc nonzero {val } { test_nonzero $val }
check_double 0 nonzero "nonzero" 10
check_double 1 nonzero "nonzero" 0
check_double 0 nonzero "nonzero" -10

set actual [ catch { test_nonnull NULL } err_msg ]
if { ($actual != 1) ||
     ([ string equal $err_msg "ValueError Received a NULL pointer." ] != 1) } {
	error "Test 'test_nonnull' with null value fail"
}
set nonnull [ get_nonnull ]
test_nonnull $nonnull
