
# This is the imports runtime testcase. 

if { [ string match $tcl_platform(os) Windows* ] == 1 } {
    if [ catch { load ./imports_a.dll imports_a} err_msg ] {    ;# Windows
        puts stderr "Could not load dll:\n$err_msg"
        exit 1
    }
    if [ catch { load ./imports_b.dll imports_b} err_msg ] {    ;# Windows
        puts stderr "Could not load dll:\n$err_msg"
        exit 1
    }
} else {
    if [ catch { load ./imports_a.so imports_a} err_msg ] {
        puts stderr "Could not load shared object:\n$err_msg"
        exit 1
    }
    if [ catch { load ./imports_b.so imports_b} err_msg ] {
        puts stderr "Could not load shared object:\n$err_msg"
	exit 1
    }
}

set x [new_B]
A_hello $x

