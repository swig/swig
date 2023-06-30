<?php

require "tests.php";

check::functions(array('va_static_cast'));
check::classes(array('cpp14_auto_return_type', 'X'));
check::classmethods("X",array("__construct","__set","__isset","__get","a"));

// No new vars
check::globals(array());

check::equal(va_static_cast(), 42);
$x = new X();
check::equal($x->a(), "a string");
