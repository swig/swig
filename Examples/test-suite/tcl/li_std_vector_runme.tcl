
if [ catch { load ./li_std_vector[info sharedlibextension] li_std_vector} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}

# # Regression test for bug fixed in SWIG 4.2.0.
if {[sum []] != 0} { error "bad vector sum" }
