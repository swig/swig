<?

	dl("libexample.so");

	# First create some objects using the pointer library.

	print "Testing the pointer library\n";

	$a = ptrcreate("int", 37);
	$b = ptrcreate("int", 42);
	$c = ptrcreate("int");

	print "	a = $a\n";
	print "	b = $b\n";
	print "	c = $x\n";

	# Call the add() function wuth some pointers
	add($a,$b,$c);

	# Now get the result
	$r = ptrvalue($c);

	print "	37 + 42 = $r\n";

	# Clean up the pointers
	ptrfree($a);
	ptrfree($b);
	ptrfree($c);

	# Now try the typemap library
	# This should be much easier. Now how it is no longer
	# necessary to manufacture pointers.

	print "Trying the typemap library\n";
	$r = sub(37,42);
	print "	37 - 42 = $r\n";

	# Now try the version with multiple return values
	# print "Testing multiple return values\n";
	# ($q,$r) = divide(42,37);
	# print "	42/37 = $q remainder $r\n";

?>
