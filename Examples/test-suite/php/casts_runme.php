<?php

require "tests.php";

// No new functions
check::functions(array());
// New classes
check::classes(array('A','B'));
// No new vars
check::globals(array());

# Make sure $b inherits hello() from class A
$b=new B();
$b->hello();

check::done();
