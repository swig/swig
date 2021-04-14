<?php

require "tests.php";
require "cpp_basic.php";

// New functions
check::functions(array('get_func1_ptr','get_func2_ptr','test_func_ptr'));
// New classes
check::classes(array('cpp_basic','Foo','FooSub','FooSubSub','Bar','Fl_Window'));
// No new vars
check::globals(array());

$f = new Foo(3);
$f->func_ptr = get_func1_ptr();
check::equal(test_func_ptr($f, 7), 2*7*3, "get_func1_ptr() didn't work");
$f->func_ptr = get_func2_ptr();
check::equal(test_func_ptr($f, 7), -7*3, "get_func2_ptr() didn't work");

check::done();
