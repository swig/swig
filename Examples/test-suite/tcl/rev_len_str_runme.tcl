
if [ catch { load ./rev_len_str[info sharedlibextension] Rev_len_str} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}

Test t
set str "hile"
if { [ t strlen $str ] != 4 } {
   puts stderr "bad multi-arg typemap"
   exit 1
}

# The Escape Sequence of zero is translated to 2 UTF-8 bytes,
# as done in Modified UTF-8.
# Standard UTF-8 repreasent zero as a single byte with value zero.
set str2 "hi\u0000"
if { [ t strlen $str2 ] != 4 } {
   puts stderr "bad multi-arg typemap"
   exit 1
}
