<?php

require "tests.php";

check::functions(array());

check::classes(array('Test'));

$t = new Test();
$str = 'hile';
check::equal(4, $t->strlen($str), "bad multi-arg typemap");
check::equal(4, $t->strlen("hil\000"), "bad multi-arg typemap");

check::done();
