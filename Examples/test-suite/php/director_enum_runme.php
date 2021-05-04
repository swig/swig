<?php

require "tests.php";

// No new functions
check::functions(array());
// New classes
check::classes(array('director_enum','Foo','A','B','A2','B2'));
// No new vars
check::globals(array());

class MyFoo extends Foo {
  function say_hi($val) {
    return $val;
  }
}

$b = new Foo();
$a = new MyFoo();

check::equal($a->say_hi(director_enum::hello), $b->say_hello(director_enum::hi), "say failed");

check::done();
