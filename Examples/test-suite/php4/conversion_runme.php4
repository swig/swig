<?php
// Sample test file

require "tests.php4";
require "conversion.php";

check::classes(array("foo","bar"));
$bar=new Bar;
check::classname("bar",$bar);
$foo=$bar->toFoo();
check::classname("foo",$foo);

check::done();
?>
