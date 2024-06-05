<?php

require "tests.php";

// New functions
check::functions(array('bar', 'test2', 'xx', 'yy'));
// New classes
check::classes(array('constant_expr'));
// New vars
check::globals(array('X','a','d_array','s1a','s2a','s2b','s3a','s3b','s4a','s4b','s5a','s5b','s6a','s6b','s7a','s7b','s8a','s8b', 's9a'));

check::equal(XX, xx());
check::equal(YY, yy());

check::equal(constant_expr::XX, constant_expr::xx());
check::equal(constant_expr::YY, constant_expr::yy());

check::done();
