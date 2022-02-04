<?php

require "tests.php";

// No new functions
check::functions(array());
// New classes
check::classes(array('Foo'));
// No new vars
check::globals(array());

check::equal(Foo::fooCount(), 0, "no Foo objects expected");
$foo = Foo::makeFoo();
check::equal(get_class($foo), "Foo", "static failed");
check::equal(Foo::fooCount(), 1, "1 Foo object expected");
$bar = $foo->makeMore();
check::equal(get_class($bar), "Foo", "regular failed");
check::equal(Foo::fooCount(), 2, "2 Foo objects expected");
$foo = null;
check::equal(Foo::fooCount(), 1, "1 Foo object expected");
$bar = null;
check::equal(Foo::fooCount(), 0, "no Foo objects expected");

check::done();
