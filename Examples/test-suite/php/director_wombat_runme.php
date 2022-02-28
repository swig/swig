<?php

require "tests.php";

// No new functions
check::functions(array());
check::classes(array('Bar', 'Foo_integers'));
// No new vars
check::globals(array());

// Test base class functionality
$barObj = new Bar();

// Bar::meth should return a Foo_integers instance
$fooIntsObj = $barObj->meth();
check::equal(get_class($fooIntsObj), "Foo_integers", "wrong class");

check::equal($fooIntsObj->meth(42) , 42, "Foo_integers::meth(n) should return n");

//
// Now subclass Foo_integers, but override its virtual method
// meth(n) so that it returns the number plus one.
//
class MyFooInts extends Foo_integers {
  function meth($n) {
    return $n + 1;
  }
}

//
// Subclass Bar and override its virtual method meth()
// so that it returns a new MyFooInts instance instead of
// a Foo_integers instance.
//
class MyBar extends Bar {
  function meth() {
    return new MyFooInts();
  }
}

//
// Now repeat previous tests:
//
// Create a MyBar instance...
//
$barObj = new MyBar();

// MyBar::meth should return a MyFooInts instance
$fooIntsObj = $barObj->meth();
check::equal(get_class($fooIntsObj), "MyFooInts", "wrong class");

check::equal($fooIntsObj->meth(42) , 43, "MyFooInts::meth(n) should return n + 1");
