<?php

require "tests.php";
require "director_default.php";

// New functions
check::functions(array('foo_msg','foo_getmsg','bar_msg','bar_getmsg','defaultsbase_defaultargs','defaultsderived_defaultargs'));
// New classes
check::classes(array('Foo','Bar','DefaultsBase','DefaultsDerived'));
// No new vars
check::globals(array());

$f = new Foo();
$f = new Foo(1);

$f = new Bar();
$f = new Bar(1);

check::done();
