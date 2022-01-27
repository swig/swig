<?php

require "tests.php";

check::functions(array());
check::classes(array('OverloadedClass','OverloadedPointers','OverloadedGetSet'));
check::globals(array());

$o = new OverloadedGetSet;
check::equal($o->rw(), 42, "get_set() initial value not 42");
check::equal($o->rw(7), null, "get_set() failed to set");
check::equal($o->rw(), 7, "get_set() didn't return back set value");

check::done();
