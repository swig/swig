<?php

require "tests.php";

// No new functions
check::functions(array());
// New classes
check::classes(array('Bar', 'Base'));
// No new vars
check::globals(array());

class MyBar extends Bar {
  function pang() {
    return "MyBar::pang()";
  }
}

$a = new MyBar();
check::equal($a->pang(), "MyBar::pang()", "MyBar::pang() not called as expected");
$b = new Bar();
check::equal($b->pang(), "Bar::pang()", "Bar::pang() not called as expected");

check::done();
