<?php

require "example.php";

echo "Version - " . ((new ReflectionExtension('example'))->getVersion());
?>
