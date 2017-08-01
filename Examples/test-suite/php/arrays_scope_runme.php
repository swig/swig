<?php

require "tests.php";
require "arrays_scope.php";

// New classes
check::classes(array(arrays_scope,Bar));
// New functions
check::classmethods(Bar,array(__construct,__set,__isset,__get,blah));

$bar=new bar();

check::done();
?>
