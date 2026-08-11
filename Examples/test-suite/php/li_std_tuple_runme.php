<?php

require "tests.php";

// Test make_int_double returns a valid IntDoubleTuple
$t = make_int_double(10, 20.5);

// Test sum_pair_values with a tuple from make_int_double
$t2 = make_int_double(3, 4.5);
$r = sum_pair_values($t2);
check::equal($r, 7.5, "sum_pair_values test failed: $r");

// Test pass_tuples with two IntDoubleTuples
$t3 = make_int_double(1, 2.5);
$t4 = make_int_double(10, 20.0);
$t5 = pass_tuples($t3, $t4);

check::done();
