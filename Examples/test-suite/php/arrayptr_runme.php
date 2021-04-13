<?php

require "tests.php";
require "arrayptr.php";

// New functions
check::functions(array('foo'));
// No new classes
check::classes(array());
// No new vars
check::globals(array());

check::done();
