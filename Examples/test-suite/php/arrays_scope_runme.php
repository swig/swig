<?php

require "tests.php";
require "arrays_scope.php";

// No new functions
check::functions(array(new_bar,bar_blah));
// No new classes
check::classes(array(arrays_scope,Bar));
// now new vars
check::globals(array());

$bar=new bar();

check::done();
?>
