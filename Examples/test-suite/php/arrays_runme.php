<?php

require "tests.php";

check::functions(array('fn_taking_arrays','newintpointer','setintfrompointer','getintfrompointer','array_pointer_func'));
check::classes(array('arrays','SimpleStruct','ArrayStruct','CartPoseData_t'));
check::globals(array());

$ss=new simplestruct();
check::classname('simplestruct',$ss);

$as=new arraystruct();
$as->array_c="abc";
check::equal($as->array_c,"a",'$as->array_c=="a"');
check::equal(isset($as->array_const_i),TRUE,'isset($as->array_const_i)');

check::done();
