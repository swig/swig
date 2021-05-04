<?php

require "tests.php";

// New functions
check::functions(array('is_python_builtin'));
// New classes
check::classes(array('StaticMemberTest','StaticFunctionTest','cpp_static','StaticBase','StaticDerived'));
// No new vars
check::globals(array());

check::done();
