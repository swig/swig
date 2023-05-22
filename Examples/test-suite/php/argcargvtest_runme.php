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
check::equal(mainv($targs, 0), 'hi', 'Test main typemap 2a');
check::equal(mainv($targs, 1), 'hola', 'Test main typemap 2b');
check::equal(mainv($targs, 2), '<<NULL>>', 'Test main typemap 2c');

$error = 0;
try {
    mainv('hello', 1);
    $error = 1;
}
catch (exception $e) {
}
check::equal($error, 0, 'Test main typemap 3');

initializeApp($largs);

# Check that an empty array works.
$empty_args = [];
check::equal(mainc($empty_args), 0, "test main typemap 4");
check::equal(mainv($empty_args, 0), '<<NULL>>', 'Test main typemap 4a');

# Check that empty strings are handled.
$empty_string = ["hello", "", "world"];
check::equal(mainc($empty_string), 3, "test main typemap 5");
check::equal(mainv($empty_string, 0), "hello", "test main typemap 6a");
check::equal(mainv($empty_string, 1), "", "test main typemap 6b");
check::equal(mainv($empty_string, 2), "world", "test main typemap 6c");
check::equal(mainv($empty_string, 3), "<<NULL>>", "test main typemap 6d");

check::done();
