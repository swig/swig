<?php

require "tests.php";

check::functions(array('trigger_internal_swig_exception'));
check::classes(array('Foo', 'exception_memory_leak'));
// No new vars
check::globals(array());

$a = new Foo();
check::equal(Foo::get_count(), 1, "Should have 1 Foo objects");
$b = new Foo();
check::equal(Foo::get_count(), 2, "Should have 2 Foo objects");

// Normal behaviour
trigger_internal_swig_exception("no problem", $a);
check::equal(Foo::get_count(), 2, "Should have 2 Foo objects");
check::equal(Foo::get_freearg_count(), 1, "freearg should have been used once");

// SWIG exception triggered and handled.
trigger_internal_swig_exception("null", $b);
check::equal(Foo::get_count(), 2, "Should have 2 Foo objects");
check::equal(Foo::get_freearg_count(), 2, "freearg should have been used twice");
