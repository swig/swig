<?php

require "tests.php";

// No new functions
check::functions(array());
// New classes
check::classes(array('Geometry','Point','Circle'));
// No new vars
check::globals(array());

$circle = Geometry::create(Geometry::CIRCLE);
$r = $circle->radius();
check::equal($r, 1.5, "r failed");

$point = Geometry::create(Geometry::POINT);
$w = $point->width();
check::equal($w, 1.0, "w failed");

$point = Geometry::create(Geometry::SHAPELESS);
check::equal($point, NULL, "NULL failed");

check::done();
