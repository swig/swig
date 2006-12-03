<?php
// Sample test file

require "tests.php4";
require "extend_template_ns.php";

check::classes(array("foo_one"));
$foo=new Foo_One();
check::equal(2,$foo->test1(2),"test1");
check::equal(3,$foo->test2(3),"test2");

check::done();
?>
