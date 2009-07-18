<?php
// Sample test file

require "tests.php";
require "rename_scope.php";

check::classes(array("rename_scope","Interface_UP","Interface_BP","Natural_UP","Natural_BP","Bucket"));

check::classmethods("Interface_UP",array("__construct"));
check::classmethods("Interface_BP",array("__construct"));
check::classmethods("Natural_UP",array("__construct","rtest"));
check::classmethods("Natural_BP",array("__construct","rtest"));
check::classparent("Natural_UP","Interface_UP");
check::classparent("Natural_BP","Interface_BP");

check::done();
?>
