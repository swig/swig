<?php

require "tests.php";

check::functions(array('fn_taking_arrays','newintpointer','setintfrompointer','getintfrompointer','array_pointer_func'));
check::classes(array('arrays','SimpleStruct','ArrayStruct','CartPoseData_t'));
check::globals(array('array_shifted_size'));

$ss=new simplestruct();
check::classname('simplestruct',$ss);

$as=new arraystruct();
$as->array_c="a";
check::equal($as->array_c,"a",'$as->array_c=="a"');
try {
  $as->array_c="abc";
  check::fail("set array_c overlong string");
} catch (ValueError $e) {
}
check::equal($as->array_c,"a",'$as->array_c=="a"');
check::equal(isset($as->array_const_i),TRUE,'isset($as->array_const_i)');

// A flexible array member is a char[] with no size, so it is read only
$fca=new FlexibleCharArray();
try {
  $fca->chars="abc";
  check::fail("set FlexibleCharArray chars");
} catch (Error $e) {
}

check::done();
