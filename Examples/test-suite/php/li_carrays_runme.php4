<?php
// Sample test file

require "tests.php4";
require "li_carrays.php";

// No new functions
check::functions(array(new_intarray,delete_intarray,intarray_getitem,intarray_setitem));
// No new classes
check::classes(array(doubleArray));
// now new vars
check::globals(array());

check::done();
?>
