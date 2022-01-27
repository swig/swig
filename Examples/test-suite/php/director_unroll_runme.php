<?php

require "tests.php";

// No new functions
check::functions(array());
// New classes
check::classes(array('Foo','Bar'));
// No new vars
check::globals(array());

class MyFoo extends Foo {
  function ping() {
    return "MyFoo::ping()";
  }
}

$a = new MyFoo();

$b = new Bar();

$b->set($a);
$c = $b->get();

// FIXME: The python version checks that a.this == c.this, but we don't seem
// to have a way to check this with the PHP bindings we generate.

check::done();
