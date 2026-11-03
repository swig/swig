<?php

require "tests.php";

check::equal(c_array_first(), 1, "c_array_first()");
check::classname("c_Override", new c_Override());
if (PHP_VERSION_ID >= 80300) {
  check::equal((new ReflectionClass("Override"))->getExtensionName(), "Core", "built-in class Override replaced");
}

check::done();
