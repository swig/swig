<?php

require "tests.php";

// New functions
check::functions(array('self'));
// New classes
check::classes(array('Project','ProjectBar','ProjectFoo'));
// No new vars
check::globals(array());

$f = new ProjectFoo();
// This resulted in "Fatal error: Class 'Foo' not found"
$f->get_self();

Project::self(new ProjectBar());

check::done();
