<?php

require "tests.php";

check::functions(array('f', 'spaceship'));
check::classes(array('cpp20_spaceship_operator','A'));
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

check::done();
