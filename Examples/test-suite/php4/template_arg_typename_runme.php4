<?php
// Sample test file

require "tests.php4";
require "template_arg_typename.php";

// No new functions
check::functions(array());
// No new classes
check::classes(array(unaryfunction_bool_bool,boolunaryfunction_bool));
$ufbb=new unaryfunction_bool_bool();
check::is_a($ufbb,"unaryfunction_bool_bool");

unset($whatisthis);
$bufb=new boolunaryfunction_bool(&$whatisthis);
check::is_a($bufb,"boolunaryfunction_bool");

check::done();
?>
