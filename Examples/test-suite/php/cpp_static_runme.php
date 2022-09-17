<?php

require "tests.php";

// No new functions
check::functions(array());
// New classes
check::classes(array('StaticMemberTest','StaticFunctionTest','cpp_static','StaticBase','StaticDerived'));
// No new vars
check::globals(array());

check::done();
