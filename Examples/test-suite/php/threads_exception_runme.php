<?php

require "tests.php";

// No new functions
check::functions(array());
// Check classes.
check::classes(array('Exc','Test','threads_exception'));
// No new vars
check::globals(array());

$t = new Test();
try {
    $t->unknown();
} catch (Exception $e) {
    check::equal($e->getMessage(), 'C++ A * exception thrown', '');
}

try {
    $t->simple();
} catch (Exception $e) {
    check::equal($e->getCode(), 37, '');
}

try {
    $t->message();
} catch (Exception $e) {
    check::equal($e->getMessage(), 'I died.', '');
}

try {
    $t->hosed();
} catch (Exception $e) {
    check::equal($e->getMessage(), 'C++ Exc exception thrown', '');
}

foreach (Array(1,2,3,4) as $i) {
    try {
	$t->multi($i);
    } catch (Exception $e) {
    }
}

check::done();
