
# This is the import runtime testcase. 

if { [ string match $tcl_platform(os) Windows* ] == 1 } {
    if [ catch { load ./import_a.dll import_a} err_msg ] {    ;# Windows
        puts stderr "Could not load dll:\n$err_msg"
        exit 1
    }
    if [ catch { load ./import_b.dll import_b} err_msg ] {    ;# Windows
        puts stderr "Could not load dll:\n$err_msg"
        exit 1
    }
} else {
    if [ catch { load ./import_a.so import_a} err_msg ] {
        puts stderr "Could not load shared object:\n$err_msg"
        exit 1
    }
    if [ catch { load ./import_b.so import_b} err_msg ] {
        puts stderr "Could not load shared object:\n$err_msg"
	exit 1
    }
}

set x [new_B]
A_hello $x

