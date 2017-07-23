<?php

require "tests.php";
require "casts.php";

// No new classes
check::classes(array(A,B));
// New functions
check::classmethods(A,array(__construct,__set,__isset,__get,hello));
check::classmethods(B,array(__construct,__set,__isset,__get,hello));
// now new vars
check::globals(array());

# Make sure $b inherites hello() from class A
$b=new B();
$b->hello();

check::done();
?>
