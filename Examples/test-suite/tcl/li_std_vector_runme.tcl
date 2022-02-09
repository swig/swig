
if [ catch { load ./li_std_vector[info sharedlibextension] li_std_vector} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}

# Regression test for bug fixed in SWIG 4.1.0.
if {[sum []] != 0} { error "bad vector sum" }

IntPtrVector v 6
if {[v empty] != 0} { error "bad std::vector::empty()" }
if {[v size] != 6} { error "bad std::vector::size()" }
# Test that calling get succeeds
v get 0
v pop
if {[v size] != 5} { error "bad std::vector::size()" }
