
if { [ string match $tcl_platform(platform) "windows" ] == 1 } {
    if [ catch { load ./overload_copy.dll overload_copy} err_msg ] {
        puts stderr "Could not load dll:\n$err_msg"
    }
} else {
    if [ catch { load ./overload_copy.so overload_copy} err_msg ] {
        puts stderr "Could not load shared object:\n$err_msg"
    }
}

Foo f
Foo g [f cget -this]





