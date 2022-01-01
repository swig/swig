<?php
require "tests.php";

$f = new Foo();
check::equal($f->test(), 0, '$f->test()');
check::equal($f->test(3), 1, '$f->test(3)');
check::equal($f->test("hello"), 2, '$f->test("hello")');
check::equal($f->test(3.0, 2.0), 5.0, '$f->test(3.0, 2.0)');
check::equal($f->test(3.0), 1003.0, '$f->test(3.0)');

check::done();
