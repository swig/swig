<?php

require "tests.php";

check::functions(array('malloc', 'memmove', 'cdata', 'cdata_int', 'cdata_double'));
check::classes(array('li_cdata_cpp'));
// No new vars
check::globals(array());

$s = "ABC\0abc";
$m = malloc(256);
memmove($m, $s);
$ss = cdata($m, 7);

check::equal($ss, "ABC\0abc", "failed");

check::done();
