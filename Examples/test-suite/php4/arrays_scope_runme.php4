<?php
// Sample test file

require "tests.php4";
require "arrays_scope.php";

// No new functions
check::functions(array());
// No new classes
check::classes(array(bar));
// now new vars
check::globals(array());

$bar=new bar();

check::done();
?>
