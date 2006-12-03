<?php
// Sample test file

require "tests.php4";
require "add_link.php";

// No new functions
check::functions(array());
// No new classes
check::classes(array(foo));

$foo=new foo();
check::is_a($foo,foo);

$foo_blah=$foo->blah();
check::is_a($foo_blah,foo);

//fails, can't be called as a class method, should allow and make it nil?
//$class_foo_blah=foo::blah();
//check::is_a($class_foo_blah,foo);

check::done();
?>
