<?php

require "tests.php";
require "arrays_global.php";

check::functions(array(test_a,test_b,new_simplestruct,new_material));
check::classes(array(arrays_global,SimpleStruct,Material));
// The size of array_c is 2, but the last byte is \0, so we can only store a
// single byte string in it.
check::set(array_c,"Z");
check::equal("Z",check::get(array_c),"set array_c");
check::set(array_c,"xy");
check::equal("x",check::get(array_c),"set array_c");
check::set(array_c,"h");
check::equal("h",check::get(array_c),"set array_c");

check::done();
?>
