<?php

require "tests.php";
require "php_pragma.php";


check::equal('1.5',(new ReflectionExtension('php_pragma'))->getVersion(),"1.5==version(php_pragma)");

check::done();

?>
