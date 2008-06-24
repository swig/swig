<?php
// Sample test file

require "tests.php4";
require "arrays_global.php";

check::functions(array(test_a,test_b,new_simplestruct,new_material));
check::classes(array(arrays_global,SimpleStruct,Material));
check::globals(array(array_c,array_sc,array_uc,array_s,array_us,array_i,array_ui,array_l,array_ul,array_ll,array_f,array_d,array_struct,array_structpointers,array_ipointers,array_enum,array_enumpointers,array_const_i,beginstring_fix44a,beginstring_fix44b,beginstring_fix44c,beginstring_fix44d,beginstring_fix44e,beginstring_fix44f,chitmat,hitmat_val,hitmat));
check::set(array_c,"hac");
check::equal("ha",check::get(array_c,"ha"),"set array_c");

check::done();
?>
