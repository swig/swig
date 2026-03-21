
if [ catch { load ./li_cdata[info sharedlibextension] Li_cdata} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}

# Ascii codes of "ABC\0abc"
set s { 65 66 67 0 97 98 99 }
set m [ malloc 256 ]
memmove $m $s
set ss [ cdata $m 7 ]
# Convert list of integers to string
set a ""
foreach i $ss {
    append a "[format %c $i]"
}
if {$a != "ABC\u0000abc"} {
    puts stderr "failed"
    exit 1
}
