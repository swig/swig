<?php

require "tests.php";
require "cpp_static.php";

// New functions
check::functions(array(staticfunctiontest_static_func,staticfunctiontest_static_func_2,staticfunctiontest_static_func_3));
// New classes
check::classes(array(StaticMemberTest,StaticFunctionTest));
// New vars
check::globals(array(staticmembertest_static_int));

check::done();
?>
