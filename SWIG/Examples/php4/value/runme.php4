<?php

	require "example.php";


	$v = new_vector(1.0,2.0,3.0);
	$w = new_vector(10.0,11.0,12.0);

	echo "I just created the following vector\n";
	vector_print($v);
	vector_print($w);

	echo "\nNow I'm going to compute the dot product\n";

	$d = dot_product($v, $w);

	echo "dot product = $d (should be 68)\n";

	echo "\nNow I'm going to add the vectors together\n";

	$r = vector_add($v, $w);

	vector_print($r);

	echo "The value should be (11,13,15)\n";

	echo "\nNow I'm going to clean up the return result\n";

#	free($r);

	echo "Good\n";

?>


