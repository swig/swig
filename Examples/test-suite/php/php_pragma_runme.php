<?php

require "tests.php";

// No new functions
check::functions(array());
// No new classes
check::classes(array());
// No new vars
check::globals(array());

check::equal('1.5',(new ReflectionExtension('php_pragma'))->getVersion(),"1.5==version(php_pragma)");

check::done();
