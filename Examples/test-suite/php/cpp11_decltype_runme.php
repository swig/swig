<?php

require "tests.php";

// No new functions
check::functions(array());
check::classes(array('A', 'B'));
// No new vars
check::globals(array());

$a = new A();

$a->i = 5;
check::equal($a->i, 5, 'Assignment to $a->i failed.');

$a->j = 10;
check::equal($a->j, 10, 'Assignment to $a->j failed.');

$b = $a->get_number(5);
check::equal($b, 10, 'get_number(5) should return 10.');

$b = $a->get_number(6);
check::equal($b, 0, 'get_number(6) should return 0.');
