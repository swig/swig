<?php

require "tests.php";
require "autodoc.php";
// In 2.0.6 and earlier, the constant was misnamed.
if (gettype(autodoc::FUNC_CB_CALLBACK) !== 'resource') die("autodoc::FUNC_CB_CALLBACK not a resource\n");

check::done();
?>
