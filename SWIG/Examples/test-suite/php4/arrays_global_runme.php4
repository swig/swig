<?php
// Sample test file

require "tests.php4";
require "arrays_global.php";

// No new functions
check::functions(array());
// No new classes
check::classes(array(simplestruct));
check::globals(array(array_c,array_sc,array_uc,array_s,array_us,array_i,array_ui,array_l,array_ul,array_ll,array_f,array_d,array_struct,array_structpointers,array_ipointers,array_enum,array_enumpointers,array_const_i));
check::set(array_c,"hac");
check::equal("ha",check::get(array_c,"ha"),"set array_c");

check::done();
?>
