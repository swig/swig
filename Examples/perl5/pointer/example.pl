# file: example.pl

use example;

# First create some objects using the pointer library.
print "Testing the pointer library\n";
$a = example::ptrcreate("int",37);
$b = example::ptrcreate("int",42);
$c = example::ptrcreate("int");  

print "     a = $a\n";
print "     b = $b\n";
print "     c = $c\n";

# Call the add() function with some pointers
example::add($a,$b,$c);

# Now get the result
$r = example::ptrvalue($c);
print "     37 + 42 = $r\n";

# Clean up the pointers
example::ptrfree($a);
example::ptrfree($b);
example::ptrfree($c);

# Now try the typemap library
# This should be much easier. Now how it is no longer
# necessary to manufacture pointers.

print "Trying the typemap library\n";
$r = example::sub(37,42);
print "     37 - 42 = $r\n";

# Now try the version with multiple return values

print "Testing multiple return values\n";
($q,$r) = example::divide(42,37);
print "     42/37 = $q remainder $r\n";



