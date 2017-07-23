<?php

require "tests.php";
require "add_link.php";

check::classes(array(Foo));
check::classmethods(Foo,array(__construct,__set,__isset,__get,blah));

$foo=new foo();
check::is_a($foo,foo);

$foo_blah=$foo->blah();
check::is_a($foo_blah,foo);

//fails, can't be called as a class method, should allow and make it nil?
//$class_foo_blah=foo::blah();
//check::is_a($class_foo_blah,foo);

check::done();
?>
