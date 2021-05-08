<?php

require "tests.php";

// No new functions
check::functions(array());
// New classes
check::classes(array('arrays_scope','Bar'));
// No new globals
check::globals(array());

$bar=new bar();

check::done();
