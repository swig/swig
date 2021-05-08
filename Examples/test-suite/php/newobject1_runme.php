<?php

require "tests.php";

// No new functions
check::functions(array());
// New classes
check::classes(array('Foo'));
// No new vars
check::globals(array());

$foo = Foo::makeFoo();
check::equal(get_class($foo), "Foo", "static failed");
$bar = $foo->makeMore();
check::equal(get_class($bar), "Foo", "regular failed");

check::done();
