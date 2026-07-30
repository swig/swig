if [ catch { load ./charptr_fragment[info sharedlibextension] Charptr_fragment} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}

if {[getCharBuf] != "hello"} {
     puts stderr "getCharBuf failed"
     exit 1
}
