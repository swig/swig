<?php

require "tests.php";

// No new functions
check::functions(array());
check::classes(array('import_nomodule'));
// No new globals
check::globals(array());

// SWIGPHP doesn't currently support the "violation of the type system" which
// is tested by this testcase.
exit(0);

$f = import_nomodule::create_Foo();
import_nomodule::test1($f,42);
import_nomodule::delete_Foo($f);

$b = new Bar();
import_nomodule::test1($b,37);

check::done();
