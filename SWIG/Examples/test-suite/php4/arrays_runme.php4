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
//check::classname(simplestruct,$ss);
echo "Will set\n";
$ss->array_c="ab";
echo "Have set\n";
var_dump($ss);
var_dump($ss->array_c);
$x=$ss->array_c;
exit;
var_dump($x);
var_dump($ss->array_c);
var_dump($ss->array_c);
var_dump($ss->array_c);
var_dump($ss);
//check::equal($ss->array_c,"ab",'$ss->array_c="ab"');
var_dump($ss->array_c);
var_dump($ss->array_struct);
//fn_taking_arrays($ss->array_struct);

check::done();
?>
