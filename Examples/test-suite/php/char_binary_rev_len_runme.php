<?php

require "tests.php";

check::functions(array());

check::classes(array('Test'));

$t = new Test();
$str = 'hile';
check::equal(4, $t->strlen($str), "bad multi-arg typemap 1");
check::equal(4, $t->strlen("hil\000"), "bad multi-arg typemap 2");

$t2 = new Test($str);
check::equal(4, $t2->getisize(), "bad multi-arg typemap 3");
check::equal(5, $t2->strlen("hil\000a"), "bad multi-arg typemap 4");

check::done();
