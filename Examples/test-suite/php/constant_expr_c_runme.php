<?php

require "tests.php";

// New functions
check::functions(array('xx', 'yy'));
// New classes
check::classes(array('constant_expr_c'));
// New vars
check::globals(array('X','d_array','s1a','s2a','s2b','s3a','s3b','s4a','s4b','s5a','s5b','s6a','s6b','s7a','s7b','s8a','s8b','s9a', 's10a', 's10b'));

check::equal(XX, xx());
check::equal(YY, yy());

check::equal(s2a_get(), 10);
check::equal(s2b_get(), 10);
check::equal(s4a_get(), 11 * s5a_get());
check::equal(s4b_get(), 11 * s5b_get());

check::done();
