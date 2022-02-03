<?php

require "tests.php";

check::functions(array('getBar','idFromGetBar'));
check::classes(array('Foo','Bar','Baz','director_alternating'));
// No new vars
check::globals(array());

$id = director_alternating::getBar()->id();
check::equal($id, director_alternating::idFromGetBar(), "idFromGetBar() failed");
