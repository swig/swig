
if [ catch { load ./import_nomodule[info sharedlibextension] Import_nomodule} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}
