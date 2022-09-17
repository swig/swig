<?php

require "tests.php";

// New functions
check::functions(array('mainc', 'mainv', 'initializeapp'));
// New classes
check::classes(array('argcargvtest'));
// No new vars
check::globals(array());

$largs = array('hi', 'hola', 'hello');
check::equal(mainc($largs), 3, 'Test main typemap 1');

$targs = array('hi', 'hola');
check::equal(mainv($targs, 1), 'hola', 'Test main typemap 2');

$error = 0;
try {
    mainv('hello', 1);
    $error = 1;
}
catch (exception $e) {
}
check::equal($error, 0, 'Test main typemap 3');

initializeApp($largs);

check::done();
