<?php

require "tests.php";

check::classes(array("Foo2","MyHandle_Foo2"));

// This doesn't actually test any smart pointer stuff, just that static
// vs non-static overloading is wrapped suitable (fixed in SWIG 4.2.0).
//
// We can't make the same wrapped method both static and non-static in PHP
// so we make it non-static, and that at least allows the static version
// to be called via an object.
$foo2=new Foo2();
check::classname("foo2",$foo2);
check::equal($foo2->sum(1,2), 3);
check::equal($foo2->sum(1,2,3), 6);

check::done();
