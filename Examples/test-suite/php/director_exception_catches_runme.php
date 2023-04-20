<?php

require "tests.php";

// No new functions
check::functions(array());
// New classes
check::classes(array('BaseClass'));
// No new vars
check::globals(array());

class MyClass extends BaseClass {
  function description() {
    throw new Exception("Testing exception thrown in description()");
  }
}

$b = new MyClass();
try {
    BaseClass::call_description($b);
    check::fail("No exception thrown by BaseClass::call_description(\$b)");
} catch (Exception $e) {
    check::equal($e->getMessage(), "Testing exception thrown in description()", "Unexpected exception message: ".$e->getMessage());
}

check::done();
