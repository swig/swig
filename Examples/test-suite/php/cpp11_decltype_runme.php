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

$b->ij = 42;
check::equal($b->ij, 42, 'Assignment to $b->ij failed.');

$b->i = 7;
$b->j = 17;
$n = $b->get_number_sum(0);
check::equal($n, 24, '$b->get_number_sum(0) should return 24.');

check::equal($b->negate(true), false);

check::equal($b->negate(false), true);

check::equal(gettype($b->should_be_int), "integer");
check::equal(gettype($b->should_be_int2), "integer");
check::equal(gettype($b->should_be_int3), "integer");
check::equal(gettype($b->should_be_int4), "integer");
check::equal(gettype($b->should_be_int5), "integer");
check::equal(gettype($b->should_be_int6), "integer");
check::equal(gettype($b->should_be_int7), "integer");
check::equal(gettype($b->should_be_int8), "integer");
check::equal(gettype($b->should_be_int9), "integer");
check::equal(gettype($b->should_be_int10), "integer");

check::equal(gettype($b->should_be_ulong), "integer");
check::equal(gettype($b->should_be_ulong2), "integer");
check::equal(gettype($b->should_be_ulong3), "integer");

check::equal(gettype($b->should_be_bool), "boolean");
check::equal(gettype($b->should_be_bool2), "boolean");

check::equal(gettype($b::should_be_char), "string");
check::equal($b::should_be_char, "\0");

check::equal(gettype($b::should_be_string), "string");
check::equal($b::should_be_string, "xyzzy");

check::equal(gettype($b->should_be_enum), "integer");
