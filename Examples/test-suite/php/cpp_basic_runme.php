<?php

require "tests.php";

// New functions
check::functions(array('get_func1_ptr','get_func2_ptr','get_const_reference','get_reference','test_func_ptr'));
// New classes
check::classes(array('cpp_basic','Foo','FooSub','FooSubSub','Bar','Fl_Window','JustConst'));
// No new vars
check::globals(array());

$f = new Foo(3);
$f->func_ptr = get_func1_ptr();
check::equal(test_func_ptr($f, 7), 2*7*3, "get_func1_ptr() didn't work");
$f->func_ptr = get_func2_ptr();
check::equal(test_func_ptr($f, 7), -7*3, "get_func2_ptr() didn't work");

// Test that custom properties work - standard PHP objects support them,
// so PHP developers will expect them to work for SWIG-wrapped objects too.
check::equal($f->custom_prop, NULL, "Test unset custom property");
$f->custom_prop = "test";
check::equal($f->custom_prop, "test", "Test custom property setting");
$f->custom_prop = 42;
check::equal($f->custom_prop, 42, "Test custom property setting");

check::done();
