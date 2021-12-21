<?php
require "tests.php";

$f = new Foo();
check::equal($f->test(3), 1, '$f->test(3)');
check::equal($f->test("hello"), 2, '$f->test("hello")');
check::equal($f->test(3.5, 2.5), 3, '$f->test(3.5, 2.5)');
check::equal($f->test("hello", 20), 1020, '$f->test("hello", 20)');
check::equal($f->test("hello", 20, 100), 120, '$f->test("hello", 20, 100)');

// C default args
check::equal($f->test($f), 30, '$f->test(f)');
check::equal($f->test($f, 100), 120, '$f->test(f, 100)');
check::equal($f->test($f, 100, 200), 300, '$f->test(f, 100, 200)');

check::done();
