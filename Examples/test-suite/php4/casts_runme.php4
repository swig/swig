<?php
// Sample test file

require "tests.php4";
require "casts.php";

// No new functions
check::functions(array());
// No new classes
check::classes(array(a,b));
// now new vars
check::globals(array());

# Make sure $b inherites hello() from class A
$b=new B();
$b->hello();

check::done();
?>
