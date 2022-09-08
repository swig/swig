<?php

require "tests.php";

# Function containing rvalue reference parameter
Counter::reset_counts();
$mo = new MovableCopyable(222);
Counter::check_counts(1, 0, 0, 0, 0, 0);
MovableCopyable::movein($mo);
Counter::check_counts(1, 0, 0, 1, 0, 2);
try {
    MovableCopyable::is_nullptr($mo);
    check::fail("is_nullptr check");
} catch (TypeError $e) {
}
$mo = NULL;
Counter::check_counts(1, 0, 0, 1, 0, 2);

# Move constructor test
Counter::reset_counts();
$mo = new MovableCopyable(222);
Counter::check_counts(1, 0, 0, 0, 0, 0);
$mo_moved = new MovableCopyable($mo);
Counter::check_counts(1, 0, 0, 1, 0, 1);
try {
    MovableCopyable::is_nullptr($mo);
    check::fail("is_nullptr check");
} catch (TypeError $e) {
}
$mo = NULL;
Counter::check_counts(1, 0, 0, 1, 0, 1);
$mo_moved = NULL;
Counter::check_counts(1, 0, 0, 1, 0, 2);

# Move assignment operator test
Counter::reset_counts();
$mo111 = new MovableCopyable(111);
$mo222 = new MovableCopyable(222);
Counter::check_counts(2, 0, 0, 0, 0, 0);
$mo111->MoveAssign($mo222);
Counter::check_counts(2, 0, 0, 0, 1, 1);
try {
    MovableCopyable::is_nullptr($mo222);
    check::fail("is_nullptr check");
} catch (TypeError $e) {
}
$mo222 = NULL;
Counter::check_counts(2, 0, 0, 0, 1, 1);
$mo111 = NULL;
Counter::check_counts(2, 0, 0, 0, 1, 2);

# null check
Counter::reset_counts();
$exception_thrown = false;
try {
  MovableCopyable::movein(NULL);
} catch (TypeError $e) {
  check::str_contains($e->getMessage(), "Invalid null reference", "incorrect exception message: {$e->getMessage()}");
  $exception_thrown = true;
}
check::equal($exception_thrown, true, "Should have thrown null error");
Counter::check_counts(0, 0, 0, 0, 0, 0);

# output
Counter::reset_counts();
$mc = MovableCopyable::moveout(1234);
Counter::check_counts(2, 0, 0, 0, 1, 1);
MovableCopyable::check_numbers_match($mc, 1234);

$exception_thrown = false;
try {
  MovableCopyable::movein($mc);
} catch (TypeError $e) {
  check::str_contains($e->getMessage(), "Cannot release ownership as memory is not owned", "incorrect exception message: {$e->getMessage()}");
  $exception_thrown = true;
}
check::equal($exception_thrown, true, "Should have thrown 'Cannot release ownership as memory is not owned' error");
Counter::check_counts(2, 0, 0, 0, 1, 1);

check::done();
