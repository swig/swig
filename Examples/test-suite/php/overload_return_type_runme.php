<?php

require "tests.php";
require "overload_return_type.php";

$b = new B;
check::equal($b->foo(1), 0, "");
check::classname("A", $b->foo("test"));

?>
