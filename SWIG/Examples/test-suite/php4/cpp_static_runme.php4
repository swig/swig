<?php
// Sample test file

require "tests.php4";
require "cpp_static.php";

// No new functions
check::functions(array());
// No new classes
check::classes(array(staticmembertest,staticfunctiontest));
// now new vars
check::globals(array());

check::done();
?>
