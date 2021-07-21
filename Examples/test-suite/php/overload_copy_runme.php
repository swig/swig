<?php
require "tests.php";

// No new functions
check::functions(array());
check::classes(array('Foo'));
// No new vars
check::globals(array());

$f = new Foo();
$g = new Foo($f);

check::done();
