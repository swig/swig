<?php

require "tests.php";
require "director_unroll.php";

// No new functions
check::functions(array('foo_ping','foo_pong'));
// No new classes
check::classes(array('Foo','Bar'));

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
