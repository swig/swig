<?php

require "tests.php";
require "director_enum.php";

// New functions
check::functions(array('foo_say_hello','foo_say_hi','foo_say_bye','foo_say_hi_ref','foo_ping','foo_ping_ref','foo_ping_member_enum','a_f','a2_f'));
// New classes
check::classes(array('director_enum','Foo','A','B','A2','B2'));
// No new vars
check::globals(array());

class MyFoo extends Foo {
  function say_hi($val) {
    return $val;
  }
}

$b = new Foo();
$a = new MyFoo();

check::equal($a->say_hi(director_enum::hello), $b->say_hello(director_enum::hi), "say failed");

check::done();
