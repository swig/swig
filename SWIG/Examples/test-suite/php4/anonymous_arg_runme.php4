<?php
// Sample test file

require "tests.php4";
require "anonymous_arg.php";

check::functions(array(foo));
// these two should perform without error
foo();
foo(7);

check::done();
?>
