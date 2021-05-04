<?php

require "tests.php";

// No new functions
check::functions(array());
// New classes
check::classes(array('Foo','Bar','DefaultsBase','DefaultsDerived'));
// No new vars
check::globals(array());

$f = new Foo();
$f = new Foo(1);

$f = new Bar();
$f = new Bar(1);

check::done();
