<?php

require "tests.php";

check::functions(array('va_static_cast'));
check::classes(array('cpp14_auto_return_type'));
// No new vars
check::globals(array());

check::equal(va_static_cast(), 42);
