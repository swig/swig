<?php

require "tests.php";

// No new functions
check::functions(array());

check::classes(array('Foo'));

$foo=new foo();
check::is_a($foo,'foo');

$foo_blah=$foo->blah();
check::is_a($foo_blah,'foo');

//fails, can't be called as a class method, should allow and make it nil?
//$class_foo_blah=foo::blah();
//check::is_a($class_foo_blah,foo);

check::done();
