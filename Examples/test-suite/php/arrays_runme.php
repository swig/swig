<?php
require "tests.php";
require "arrays.php";

check::functions(array(fn_taking_arrays,newintpointer,setintfrompointer,getintfrompointer,array_pointer_func));
check::classes(array(arrays,SimpleStruct,ArrayStruct,CartPoseData_t));
// No new vars
check::globals(array());

$ss=new simplestruct();
check::classname(simplestruct,$ss);

$as=new arraystruct();
$as->array_c="abc";
check::equal($as->array_c,"ab",'$as->array_c=="ab"');

check::done();
?>
