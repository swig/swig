<?php
// Sample test file

require "tests.php";
require "li_carrays.php";

// No new functions
check::functions(array(new_intarray,delete_intarray,intarray_getitem,intarray_setitem));
// No new classes
check::classes(array(doubleArray));
// now new vars
check::globals(array());

$d = new doubleArray(10);

$d->setitem(0, 7);
$d->setitem(5, $d->getitem(0) + 3);
check::equal($d->getitem(0) + $d->getitem(5), 17., "7+10==17");

check::done();
?>
