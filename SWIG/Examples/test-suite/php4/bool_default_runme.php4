<?php
// Sample test file

require "tests.php4";
require "bool_default.php";

// No new functions
check::functions(array(foo));
// No new classes
check::classes(array());
// now new vars
check::globals(array());

check::equal(false,foo(),"foo()==false");
check::equal(false,foo(1),"foo(1)==false");
check::equal(false,foo(true),"foo(true)==false");
check::equal(true,foo(false),"foo(false)==true");
check::equal(true,foo(0),"foo(0)==true");
check::done();
?>
