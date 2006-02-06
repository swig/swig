<?php
// Sample test file

require "tests.php4";
require "class_ignore.php";

check::functions(array(do_blah));
check::classes(array(bar,boo,far,hoo));
// No new vars
check::globals(array());

$bar=new bar();
do_blah($bar);
check::classparent($bar,"");

check::done();
?>
