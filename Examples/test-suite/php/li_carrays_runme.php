<?php
require "tests.php";
require "li_carrays.php";

// Check functions.
check::functions(array(new_intarray,delete_intarray,intarray_getitem,intarray_setitem));

// Check classes.
// NB An "li_carrays" class is created as a mock namespace.
check::classes(array(li_carrays,doubleArray,AB,XY,XYArray));

// No new global variables.
check::globals(array());

$d = new doubleArray(10);

$d->setitem(0, 7);
$d->setitem(5, $d->getitem(0) + 3);
check::equal($d->getitem(0) + $d->getitem(5), 17., "7+10==17");

check::done();
?>
