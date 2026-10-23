<?php

require "tests.php";

check::functions(array('call_finalinderived','call_finalinderived2','call_meth'));
check::classes(array('Base','BaseFinalDestructor','BaseFinalDestructor2','Derived'));
// No new vars
check::globals(array());

// The final methods are not directed, so their proxies declare a return type and an override
// has to match it. Overriding them in PHP changes nothing on the C++ side.
class Derived2 extends Derived {
  function meth() { return 3; }
  function finalinderived(): int { return 98; }
  function finalinderived2(): int { return 99; }
}

$b = new Derived2();
check::equal($b->meth(), 3, "Wrong return value");

// meth is overridable, so C++ calls into PHP for it
check::equal(call_meth($b), 3, "Wrong return value");

// The final overrides are not directed, so C++ keeps its own implementations
check::equal(call_finalinderived($b), 11, "Wrong return value");
check::equal(call_finalinderived2($b), 21, "Wrong return value");
