<?php

require "tests.php";

// Check functions.
check::functions(array('new_intArray','delete_intArray','intArray_getitem','intArray_setitem','new_ABArray','delete_ABArray','ABArray_getitem','ABArray_setitem','sum_array'));

// Check classes.
// NB An "li_carrays_cpp" class is created as a mock namespace.
check::classes(array('li_carrays_cpp','doubleArray','AB','XY','XYArray','shortArray'));

// Check global variables.
check::globals(array('globalXYArray','globalABArray'));

$d = new doubleArray(10);

$d->setitem(0, 7);
$d->setitem(5, $d->getitem(0) + 3);
check::equal($d->getitem(0) + $d->getitem(5), 17., "7+10==17");

check::done();
