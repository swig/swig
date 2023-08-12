<?php

require "tests.php";

if (! class_exists("FooImpl_")) die("FooImpl_ class not found\n");
if (! 3==spam(3)) die("spam function not working right\n");

check::done();
