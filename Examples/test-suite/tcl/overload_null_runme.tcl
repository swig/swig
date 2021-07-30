
if [ catch { load ./overload_null[info sharedlibextension] overload_null} err_msg ] {
	puts stderr "Could not load shared object:\n$err_msg"
}

proc check {what expected actual} {
  if {$expected != $actual } {
    error "Failed: $what  Expected: $expected , Actual: $actual"
  }
}

set o [Overload]
set x [X]

check "test1 " 1 [$o byval1 $x]
check "test2 " 2 [$o byval1 "NULL"]

check "testX" 1 [$o byval1 $x]
check "testX" 2 [$o byval1 "NULL"]

check "testX" 3 [$o byval2 "NULL"]
check "testX" 4 [$o byval2 $x]

check "testX" 5 [$o byref1 $x]
check "testX" 6 [$o byref1 "NULL"]

check "testX" 7 [$o byref2 "NULL"]
check "testX" 8 [$o byref2 $x]

check "testX" 9 [$o byconstref1 $x]
check "testX" 10 [$o byconstref1 "NULL"]

check "testX" 11 [$o byconstref2 "NULL"]
check "testX" 12 [$o byconstref2 $x]

# const pointer references
check "testX" 13 [$o byval1cpr $x]
check "testX" 14 [$o byval1cpr "NULL"]

check "testX" 15 [$o byval2cpr "NULL"]
check "testX" 16 [$o byval2cpr $x]

# forward class declaration
check "testX" 17 [$o byval1forwardptr $x]
check "testX" 18 [$o byval1forwardptr "NULL"]

check "testX" 19 [$o byval2forwardptr "NULL"]
check "testX" 20 [$o byval2forwardptr $x]

check "testX" 21 [$o byval1forwardref $x]

check "testX" 22 [$o byval2forwardref $x]
