<?php

require "tests.php";
require "li_factory.php";

// New functions
check::functions(array('geometry_draw','geometry_create','geometry_clone_','point_draw','point_width','point_clone_','circle_draw','circle_radius','circle_clone_'));
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

check::done();
