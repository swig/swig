<?php
// Sample test file

require "tests.php4";
require "arrays.php";

// No new functions
check::functions(array(fn_taking_arrays,newintpointer,setintfrompointer,getintfrompointer));
// No new classes
check::classes(array(simplestruct,arraystruct));
// now new vars
check::globals(array());

$ss=new simplestruct();
check::classname(simplestruct,$ss);

$as=new arraystruct();
$as->array_c="abc";
check::equal($as->array_c,"ab",'$as->array_c=="ab"');

check::done();
?>
