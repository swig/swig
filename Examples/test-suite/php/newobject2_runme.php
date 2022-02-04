<?php

require "tests.php";

check::equal(fooCount(), 0, "no Foo objects expected");
$foo = makeFoo();
check::equal(get_class($foo), "Foo", "static failed");
check::equal(fooCount(), 1, "1 Foo object expected");
$bar = makeFoo();
check::equal(get_class($bar), "Foo", "regular failed");
check::equal(fooCount(), 2, "2 Foo objects expected");
$foo = null;
check::equal(fooCount(), 1, "1 Foo object expected");
$bar = null;
check::equal(fooCount(), 0, "no Foo objects expected");

check::done();
