<?php

require "tests.php";

// No new functions
check::functions(array());
// New classes
check::classes(array('Alpha','Bravo','Charlie','Delta','Ops','Prims','corePoint3d','coreCallbacks_On3dEngineRedrawnData','coreCallbacksOn3dEngineRedrawnData','coreCallbacks'));
// No new vars
check::globals(array());

$foo = new Bravo();
$s = $foo->abs_method();

check::equal($s, "Bravo::abs_method()", "s failed");

check::done();
