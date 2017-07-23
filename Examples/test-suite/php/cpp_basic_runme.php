<?php

require "tests.php";
require "cpp_basic.php";

// New Functions
check::functions(array(get_func1_ptr,get_func2_ptr,test_func_ptr));
// New classes
check::classes(array(cpp_basic,Foo,FooSub,FooSubSub,Bar,Fl_Window));
// New Class functions
check::classmethods(Foo,array(__construct,__set,__isset,__get,func1,func2,__str__));	
check::classmethods(foosubsub,array(__construct,__set,__isset,__get,__str__));
check::classmethods(bar,array(__construct,__set,__isset,__get,test,testfoo));
check::classmethods(Fl_Window,array(__construct,__set,__isset,__get,show));

$f = new Foo(3);
$f->func_ptr = get_func1_ptr();
check::equal(test_func_ptr($f, 7), 2*7*3, "get_func1_ptr() didn't work");
$f->func_ptr = get_func2_ptr();
check::equal(test_func_ptr($f, 7), -7*3, "get_func2_ptr() didn't work");

check::done();
?>
