<?php
// Sample test file

require "tests.php4";
require "valuewrapper_base.php";

check::classes(array("base","interface_bp"));
check::functions("make_interface_bp");

$ibp=make_interface_bp();
check::classname("interface_bp",$ibp);

check::done();
?>
