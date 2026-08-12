<?php

require "tests.php";

check::functions(array('f', 'spaceship'));
check::classes(array('cpp20_spaceship_operator','A','Defaulted','Deleted'));
check::globals(array('v', 'SPACE'));

//check::equal(ALIEN, true);
check::equal(SPACE_get(), 1);
check::equal(COMET, 1);
check::equal(v_get(), 42);

$x = new A(1);
$y = new A(2);

check::equal(spaceship($x, $y) < 0, true);
check::equal(spaceship($x, $x), 0);
check::equal(spaceship($y, $x) > 0, true);

check::equal(f(), 42);

// The defaulted operator<=> has a deduced return type and is ignored, the
// defaulted operator== returns bool and is wrapped.
check::classmethods("Defaulted", array("__construct","__set","__isset","__get","is_equal"));
check::classmethods("Deleted", array("__construct","__set","__isset","__get"));

$d1 = new Defaulted(1);
$d2 = new Defaulted(2);
check::equal($d1->is_equal($d1), true);
check::equal($d1->is_equal($d2), false);

check::done();
