<?php
// Sample test file

require "tests.php4";
require "class_ignore.php";

// No new functions
check::functions(array(do_blah));
// No new classes
check::classes(array(bar));
// now new vars
check::globals(array());

$bar=new bar();
do_blah($bar);
check::classparent($bar,"");

check::done();
?>
