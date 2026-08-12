<?php

require "tests.php";

check::functions(array('va_static_cast'));
check::classes(array('cpp14_auto_return_type', 'X', 'Deduced'));
check::classmethods("X",array("__construct","__set","__isset","__get","a","cref"));
check::classmethods("Deduced",array("__construct","__set","__isset","__get","toInt"));

// No new vars
check::globals(array());

check::equal(va_static_cast(), 42);
$x = new X();
check::equal($x->a(), "a string");
check::equal($x->cref(), 42);

$d = new Deduced(7);
check::equal($d->toInt(), 7);
