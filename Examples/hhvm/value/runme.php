<?php


	$v = new vector();
        $v->vector_x_set(1.0);
        $v->vector_y_set(2.0);
        $v->vector_z_set(3.0);

	$w = new vector();
        $w->vector_x_set(10.0);
        $w->vector_y_set(11.0);
        $w->vector_z_set(12.0);

	echo "I just created the following vector\n";
	vector_print($v);
	vector_print($w);

	echo "\nNow I'm going to compute the dot product\n";

	$d = dot_product($v, $w);

	echo "dot product = $d (should be 68)\n";

	echo "\nNow I'm going to add the vectors together\n";

        $r = new vector();
	vector_add($v, $w, $r);

	vector_print($r);

	echo "The value should be (11,13,15)\n";

	echo "\nNow I'm going to clean up the return result\n";

#	free($r);

	echo "Good\n";

?>


