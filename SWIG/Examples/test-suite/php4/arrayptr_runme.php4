<?php
// Sample test file

require "tests.php4";
require "arrayptr.php";

// No new functions
check::functions(array(foo));
// No new classes
check::classes(array());
// now new vars
check::globals(array());

check::done();
?>
