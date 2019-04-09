<?php

require "tests.php";
require "director_unroll.php";

// No new functions
check::functions(array('foo_ping','foo_pong'));
// No new classes
check::classes(array('Foo','Bar'));
// now new vars
check::globals(array('bar'));

class MyFoo extends Foo {
  function ping() {
    return "MyFoo::ping()";
  }
}

$a = new MyFoo();

$b = new Bar();

$b->set($a);
$c = $b->get();

// FIXME: This doesn't work for checking that they wrap the same C++ object
// because the two objects have different PHP resources, and we can't easily
// look inside those resources to see which C++ objects they refer to.
//check::equal($a->_cPtr, $c->_cPtr, "_cPtr check failed");

check::done();
?>
