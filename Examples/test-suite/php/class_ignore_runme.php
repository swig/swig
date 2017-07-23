<?php

require "tests.php";
require "class_ignore.php";

check::functions(array(do_blah));
check::classes(array(class_ignore,Bar,Boo,Far,Hoo));
// New functions
check::classmethods(Bar,array(__construct,__set,__isset,__get,blah));
check::classmethods(Boo,array(__construct,__set,__isset,__get,away));
check::classmethods(Far,array(__construct,__set,__isset,__get));
check::classmethods(Hoo,array(__construct,__set,__isset,__get));
// No new vars
check::globals(array());

$bar=new bar();
do_blah($bar);
check::classparent($bar,"");

check::done();
?>
