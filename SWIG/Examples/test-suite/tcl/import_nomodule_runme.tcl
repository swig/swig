
if { [ string match $tcl_platform(platform) "windows" ] == 1 } {
    if [ catch { load ./import_nomodule.dll import_nomodule} err_msg ] {
        puts stderr "Could not load dll:\n$err_msg"
    }
} else {
    if [ catch { load ./import_nomodule.so import_nomodule} err_msg ] {
        puts stderr "Could not load shared object:\n$err_msg"
    }
}
