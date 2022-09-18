<?php

require "tests.php";

$exception_thrown = false;
try {
  StringsThrower::charstring();
} catch (Exception $e) {
  check::str_contains($e->getMessage(), "charstring message", "incorrect exception message: {$e->getMessage()}");
  $exception_thrown = true;
}
check::equal($exception_thrown, true, "Should have thrown an exception");

$exception_thrown = false;
try {
  StringsThrower::stdstring();
} catch (Exception $e) {
  check::str_contains($e->getMessage(), "stdstring message", "incorrect exception message: {$e->getMessage()}");
  $exception_thrown = true;
}
check::equal($exception_thrown, true, "Should have thrown an exception");

check::done();
