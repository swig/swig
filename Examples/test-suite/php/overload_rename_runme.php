<?php

require "tests.php";

// No new functions
check::functions(array());
// New classes
check::classes(array('Foo'));
// No new vars
check::globals(array());

$f = new Foo(1.0);
$f = new Foo(1.0,1.0);
$f = Foo::Foo_int(1.0,1);
$f = Foo::Foo_int(1.0,1,1.0);

check::done();
