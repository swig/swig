<?php

require "tests.php";
require "overload_null.php";

$o = new Overload();
$x = new X();

check::equal(1, $o->byval1($x), "test 1");
check::equal(2, $o->byval1(null), "test 2");

check::equal(3, $o->byval2(null), "test 3");
check::equal(4, $o->byval2($x), "test 4");

check::equal(5, $o->byref1($x), "test 5");
check::equal(6, $o->byref1(null), "test 6");

check::equal(7, $o->byref2(null), "test 7");
check::equal(8, $o->byref2($x), "test 8");

check::equal(9, $o->byconstref1($x), "test 9");
check::equal(10, $o->byconstref1(null), "test 10");

check::equal(11, $o->byconstref2(null), "test 11");
check::equal(12, $o->byconstref2($x), "test 12");

# const pointer references
check::equal(13, $o->byval1cpr($x), "test 13");
check::equal(14, $o->byval1cpr(null), "test 14");

check::equal(15, $o->byval2cpr(null), "test 15");
check::equal(16, $o->byval2cpr($x), "test 16");

# forward class declaration
check::equal(17, $o->byval1forwardptr($x), "test 17");
check::equal(18, $o->byval1forwardptr(null), "test 18");

check::equal(19, $o->byval2forwardptr(null), "test 19");
check::equal(20, $o->byval2forwardptr($x), "test 20");

check::equal(21, $o->byval1forwardref($x), "test 21");

check::equal(22, $o->byval2forwardref($x), "test 22");

check::done();
?>
