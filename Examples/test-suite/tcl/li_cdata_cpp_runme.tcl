
if [ catch { load ./li_cdata_cpp[info sharedlibextension] Li_cdata_cpp} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}

# The universal character Escape Sequence is 2 bytes
set s "ABC\u0000bc"
set m [ malloc 256 ]
memmove $m $s
set ss [ cdata $m 7 ]
if {$ss != "ABC\u0000bc"} {
    puts stderr "failed"
    exit 1
}
