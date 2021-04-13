<?php

require "tests.php";
require "prefix.php";

// New functions
check::functions(array('foo_get_self'));
// New classes
check::classes(array('ProjectFoo'));
// No new vars
check::globals(array());

$f = new ProjectFoo();
// This resulted in "Fatal error: Class 'Foo' not found"
$f->get_self();

check::done();
