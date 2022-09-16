<?php

require "tests.php";

Counter::reset_counts();
$mo = new MoveOnly(111);
Counter::check_counts(1, 0, 0, 0, 0, 0);
MoveOnly::take($mo);
Counter::check_counts(1, 0, 0, 1, 0, 2);
$mo = NULL;
Counter::check_counts(1, 0, 0, 1, 0, 2);

Counter::reset_counts();
$mo = new MovableCopyable(111);
Counter::check_counts(1, 0, 0, 0, 0, 0);
MovableCopyable::take($mo);
Counter::check_counts(1, 0, 0, 1, 0, 2);
$mo = NULL;
Counter::check_counts(1, 0, 0, 1, 0, 2);

$mo = new MoveOnly(222);
MoveOnly::take($mo);
$exception_thrown = false;
try {
  MoveOnly::take($mo);
} catch (TypeError $e) {
  check::str_contains($e->getMessage(), "Cannot release ownership as memory is not owned", "incorrect exception message: {$e->getMessage()}");
  $exception_thrown = true;
}
check::equal($exception_thrown, true, "double usage of takeKlassUniquePtr should have been an error");

check::done();
