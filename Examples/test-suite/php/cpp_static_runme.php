<?php

require "tests.php";
require "cpp_static.php";

// New functions
check::functions(array('staticfunctiontest_static_func','staticfunctiontest_static_func_2','staticfunctiontest_static_func_3','is_python_builtin'));
// New classes
check::classes(array('StaticMemberTest','StaticFunctionTest','cpp_static','StaticBase','StaticDerived'));

check::done();
?>
