<?php
// Sample test file

require "tests.php4";
require "evil_diamond_prop.php";

check::classes(array("foo","bar","baz","spam"));
check::functions("test");
check::is_a("bar","foo");
check::is_a("baz","foo");
check::is_a("spam","foo");
check::is_a("spam","bar");
//No multiple inheritance introspection yet
//check::is_a("spam","baz");

$foo=new foo();
check::is_a($foo,"foo");
$foo->_foo=2;
check::equal(2,$foo->_foo,"2==foo->_foo");

$bar=new bar();
$bar->_foo=3;
check::equal(2,$bar->_foo,"2==bar->_foo");
var_dump($bar);

check::done();
?>
