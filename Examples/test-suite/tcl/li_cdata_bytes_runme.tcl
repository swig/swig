
if [ catch { load ./li_cdata_bytes[info sharedlibextension] Li_cdata_bytes} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}

set m [predefStr]
set s [cdata $m 512]
for { set i 0 } { $i < 256 } { incr i } {
  set v [lindex $s $i]
  if { $i != $v } {
    puts stderr "Value $v should be $i at index $i"
    exit 1
  }
  set i2 [expr $i + 256]
  set v2 [lindex $s $i2]
  if { $i != $v2 } {
    puts stderr "Value $v2 should be $i at index $i2"
    exit 1
  }
}
for { set i 0 } { $i < 256 } { incr i } {
  set v [expr 255 - $i]
  set i2 [expr $i + 256]
  lset s $i $v
  lset s $i2 $v
}
set m2 [malloc 512]
memmove $m2 $s
if { [verifyBytes $m2] < 0 } {
  puts stderr "verifyBytes fail"
  exit 1
}
free $m2
