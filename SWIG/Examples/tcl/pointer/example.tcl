# file: example.tcl

catch { load ./example.so example}
catch { load ./example.dll example}    ;# Windows

# First create some objects using the pointer library.
puts "Testing the pointer library"
set a [ptrcreate int 37]
set b [ptrcreate int 42]
set c [ptrcreate int]       ;# Memory for result

puts "     a = $a"
puts "     b = $b"
puts "     c = $c"

# Call the add() function with some pointers
add $a $b $c

# Now get the result
set r [ptrvalue $c]
puts "     37 + 42 = $r"

# Clean up the pointers
ptrfree $a
ptrfree $b
ptrfree $c

# Now try the typemap library
# This should be much easier. Now how it is no longer
# necessary to manufacture pointers.

puts "Trying the typemap library"
set r [sub 37 42]
puts "     37 - 42 = $r"

# Now try the version with multiple return values

puts "Testing multiple return values"
set qr [divide 42 37]
set q [lindex $qr 0]
set r [lindex $qr 1]
puts "     42/37 = $q remainder $r"



