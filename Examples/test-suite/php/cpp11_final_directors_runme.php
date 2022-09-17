<?php

require "tests.php";

// No new functions
check::functions(array());
check::classes(array('Base','BaseFinalDestructor','BaseFinalDestructor2','Derived'));
// No new vars
check::globals(array());

class Derived2 extends Derived {
  function meth() { return 3; }
}

$b = new Derived2();
check::equal($b->meth(), 3, "Wrong return value");
