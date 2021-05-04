<?php

require "tests.php";

check::functions(array('test_a','test_b'));
check::classes(array('arrays_global','SimpleStruct','Material'));
check::globals(array('array_c','array_sc','array_uc','array_s','array_us','array_i','array_ui','array_l','array_ul','array_ll','array_f','array_d','array_struct','array_structpointers','array_ipointers','array_enum','array_enumpointers','array_const_i','BeginString_FIX44a','BeginString_FIX44b','BeginString_FIX44c','BeginString_FIX44d','BeginString_FIX44e','BeginString_FIX44f','chitMat','hitMat_val','hitMat'));

// The size of array_c is 2, but the last byte is \0, so we can only store a
// single byte string in it.
check::set("array_c","Z");
check::equal("Z",check::get("array_c"),"set array_c");
check::set("array_c","xy");
check::equal("x",check::get("array_c"),"set array_c");
check::set("array_c","h");
check::equal("h",check::get("array_c"),"set array_c");

check::done();
