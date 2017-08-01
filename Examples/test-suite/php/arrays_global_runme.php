<?php

require "tests.php";
require "arrays_global.php";

check::functions(array(test_a,test_b));
check::classes(array(arrays_global,SimpleStruct,Material));
check::classmethods(SimpleStruct,array(__construct,__set,__isset,__get,double_field_set,double_field_get));
check::classmethods(Material,array(__construct,__set,__isset,__get));

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
