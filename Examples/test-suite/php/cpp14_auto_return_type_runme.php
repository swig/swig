<?php

require "tests.php";

check::functions(array('va_static_cast'));
check::classes(array('cpp14_auto_return_type', 'X', 'Deduced', 'DeducedPtr'));
check::classmethods("X",array("__construct","__set","__isset","__get","a","cref"));
check::classmethods("Deduced",array("__construct","__set","__isset","__get","toInt"));
check::classmethods("DeducedPtr",array("__construct","__set","__isset","__get","deref","cref"));

// No new vars
check::globals(array());

check::equal(va_static_cast(), 42);
$x = new X();
check::equal($x->a(), "a string");
check::equal($x->cref(), 42);

$d = new Deduced(7);
check::equal($d->toInt(), 7);
$dp = new DeducedPtr(8);
check::equal($dp->deref(), 8);
check::equal($dp->cref(), 8);

// The deleted functions with a deduced return type are not wrapped.
check::equal(method_exists('X', 'deleted'), false, "X::deleted should not be wrapped");
check::equal(function_exists('deleted_global'), false, "deleted_global should not be wrapped");
