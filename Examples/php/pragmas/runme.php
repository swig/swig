<?php

# For finding include.php
set_include_path(realpath(dirname(__FILE__)) . PATH_SEPARATOR . get_include_path());

require "example.php";

echo "Version - " . ((new ReflectionExtension('example'))->getVersion()) . "\n";
?>
