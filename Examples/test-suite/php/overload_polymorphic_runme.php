<?php

require "tests.php";

$t = new Derived();

check::equal(overload_polymorphic::test($t), 0, "test(Derived)");
check::equal(overload_polymorphic::test(1), 1, "test(1)");
check::equal(overload_polymorphic::test2($t), 1, "test2(Derived)");
check::equal(overload_polymorphic::test3($t, null, $t), 1, "test3(Derived, null, Derived)");

check::done();
