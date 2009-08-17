<?php

require "tests.php";
require "cpp_static.php";

// No new functions
check::functions(array());
// No new classes
check::classes(array(StaticMemberTest,StaticFunctionTest));
// now new vars
check::globals(array());

check::done();
?>
