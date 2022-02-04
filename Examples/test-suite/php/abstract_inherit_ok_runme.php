<?php

require "tests.php";

// No new functions
check::functions(array());

check::classes(array('Foo','Spam'));

// No new vars
check::globals(array());

// We shouldn't be able to instantiate abstract class Foo.
$class = 'Foo';
try {
    $obj = eval("new $class();");
    check::fail("Should not be able to instantiate abstract class $class");
} catch (Error $e) {
    check::equal($e->getMessage(), "Cannot instantiate abstract class $class", "Unexpected exception: {$e->getMessage()}");
}

$spam=new Spam();
check::equal(0,$spam->blah(),"spam object method");

check::done();
