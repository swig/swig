<?php

require "tests.php";

// No new functions
check::functions(array());
// New classes
check::classes(array('Minimal'));
// No new vars
check::globals(array());

class MyMinimal extends Minimal {
  function run() {
    return true;
  }
}

$c = new MyMinimal();
check::is_a($c->get(), true);
check::done();
