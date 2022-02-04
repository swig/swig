<?php
require "tests.php";

$f = new Foo();
$b = new Bar();

check::equal(spam($f), 1, "foo");

check::equal(spam($b), 2, "bar");

check::done();
