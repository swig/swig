<?php

require "tests.php";

// No new functions
check::functions(array());
// New classes
check::classes(array('SpObject'));
// No new vars
check::globals(array());

class MyObject extends SpObject{
  function getFoo() {
    return 123;
  }
}

$m = new MyObject();
check::equal($m->dummy(), 666, "1st call");
check::equal($m->dummy(), 666, "2nd call"); // Locked system

check::done();
