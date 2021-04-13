<?php

require "tests.php";
require "casts.php";

// New functions
check::functions(array('new_a','a_hello','new_b'));
// New classes
check::classes(array('A','B'));
// No new vars
check::globals(array());

# Make sure $b inherits hello() from class A
$b=new B();
$b->hello();

check::done();
