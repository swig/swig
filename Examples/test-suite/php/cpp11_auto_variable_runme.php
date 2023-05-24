<?php

require "tests.php";

// No new functions
check::functions(array());
check::classes(array('cpp11_auto_variable'));
check::globals(array('f', 't'));

check::equal(f_get(), false);
check::equal(t_get(), true);

t_set(false);
check::equal(t_get(), false);

check::equal(function_exists('f_set'), false, "f should be constant but f_set() exists");
