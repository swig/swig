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

$n = $a->get_number(5);
check::equal($n, 10, 'get_number(5) should return 10.');

$n = $a->get_number(6);
check::equal($n, 0, 'get_number(6) should return 0.');

$b = new B();

check::equal($b->a, false);

check::equal($b->b, true);

check::equal($b->negate(true), false);

check::equal($b->negate(false), true);

check::equal(gettype($b->should_be_int), "integer");
check::equal(gettype($b->should_be_int2), "integer");
check::equal(gettype($b->should_be_bool), "boolean");
