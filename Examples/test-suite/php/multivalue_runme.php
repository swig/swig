<?php

require "tests.php";

// New functions
check::functions(array('divide_l','divide_v','divide_mv'));
// New classes
check::classes(array('multivalue'));
// No new vars
check::globals(array());

$r = multivalue::divide_l(37, 5);
check::equal($r[0], 7, "Test divide_l quotient");
check::equal($r[1], 2, "Test divide_l remainder");

$r = multivalue::divide_v(41, 7);
check::equal($r[0], 5, "Test divide_v quotient");
check::equal($r[1], 6, "Test divide_v remainder");

$r = multivalue::divide_mv(91, 13);
check::equal($r[0], 7, "Test divide_mv quotient");
check::equal($r[1], 0, "Test divide_mv remainder");

check::done();
