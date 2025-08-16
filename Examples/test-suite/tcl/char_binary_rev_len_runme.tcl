
if [ catch { load ./char_binary_rev_len[info sharedlibextension] Char_binary_rev_len} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}

Test t
set str "hile"
if { [ t strlen $str ] != 4 } {
   puts stderr "bad multi-arg typemap 1"
   exit 1
}

# The Escape Sequence of zero is translated to 2 UTF-8 bytes,
# as done in Modified UTF-8.
# Standard UTF-8 repreasent zero as a single byte with value zero.
set str2 "hi\u0000"
if { [ t strlen $str2 ] != 4 } {
   puts stderr "bad multi-arg typemap 2"
   exit 1
}

Test t2 "hile"
if { [ t2 getisize ] != 4 } {
   puts stderr "bad multi-arg typemap 3"
   exit 1
}

set str3 "hi\u0000a"
if { [ t2 strlen $str3 ] != 5 } {
   puts stderr "bad multi-arg typemap 4"
   exit 1
}
