<?php
// Sample test file

require "tests.php";

// No new functions
check::functions(array());
// No new classes
check::classes(array());
// No new vars
check::globals(array());

check::done();
