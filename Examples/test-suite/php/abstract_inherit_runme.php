<?php

require "tests.php";

check::classes(array('Foo','Bar','Spam','NRFilter_i','NRRCFilter_i','NRRCFilterpro_i','NRRCFilterpri_i'));

// We shouldn't be able to instantiate any of these classes since they are all
// abstract (in each case there's a pure virtual function in the base class
// which isn't implemented).
foreach (array('Foo','Bar','Spam','NRFilter_i','NRRCFilter_i','NRRCFilterpro_i','NRRCFilterpri_i')as $class) {
    try {
	$obj = eval("new $class();");
	check::fail("Should not be able to instantiate abstract class $class");
    } catch (Error $e) {
	check::equal($e->getMessage(), "Cannot instantiate abstract class $class", "Unexpected exception: {$e->getMessage()}");
    }
}

check::done();
