<?php

require "tests.php";

// We want to fail if any extra classes/function/constants are defined.
check::werror(true);

check::classes(array("rename_camel","GeometryFactory","ByteOrderValues"));
check::functions(array("CamelCase","CamelCase1","CamelCase2","CamelCase3","lowerCamelCase","lowerCamelCase1","lowerCamelCase2","lowerCamelCase3","under_case","under_case1","under_case2","under_case3","Import","foo","hello"));
check::constants(array("HELLO","HI_THERE","BYE","SEE_YOU"));


check::done();
