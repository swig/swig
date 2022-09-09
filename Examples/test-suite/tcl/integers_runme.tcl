if [ catch { load ./integers[info sharedlibextension] integers} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}

# 32-bit long max
set val 2147483647
if {[signed_long_identity $val] != $val} {
    puts stderr "Runtime test 1 failed"
    exit 1
}

set val 3902408827
if {[unsigned_long_identity $val] != $val} {
    puts stderr "Runtime test 2 failed"
    exit 1
}

if {[signed_long_long_identity $val] != $val} {
    puts stderr "Runtime test 3 failed"
    exit 1
}

if {[unsigned_long_long_identity $val] != $val} {
    puts stderr "Runtime test 4 failed"
    exit 1
}
