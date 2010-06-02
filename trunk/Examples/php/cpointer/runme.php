<?php

	require "example.php";

	# First create some objects using the pointer library.

	print "Testing the pointer library\n";

	$a = new_intp();
	$b = new_intp();
	$c = new_intp();
	intp_assign($a,37);
	intp_assign($b,42);

	print "	a = $a\n";
	print "	b = $b\n";
	print "	c = $c\n";

	# Call the add() function wuth some pointers
	add($a,$b,$c);

	# Now get the result
	$r = intp_value($c);

	print "	37 + 42 = $r\n";

	# Clean up the pointers
	delete_intp($a);
	delete_intp($b);
	delete_intp($c);

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
