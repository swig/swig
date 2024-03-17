<?php

require "tests.php";

// New functions
check::functions(array('test_nonnegative', 'test_nonpositive', 'test_positive',
  'test_negative', 'test_nonzero', 'test_nonnull', 'get_nonnull'));
// New classes
check::classes(array('li_constraints'));
// No new vars
check::globals(array());

function check_double(bool $except, $fn, string $f, $val) {
  $actual = true;
  $d = doubleval($val);
  try {
    $fn($d);
  } catch(ValueError $e) {
    $actual = false;
    $msg = $e->getMessage();
  }
  $name = "test_" . str_replace("-", "", $f);
  if($actual) {
    check::equal($actual, $except, "Test '$name' with $val pass");
  } else {
    check::equal($actual, $except, "Test '$name' throw exception with $val");
    check::equal($msg, "Expected a " . $f . " value.", "'$name' throw proper exception");
  }
}

$nonnegative = function ($val) { test_nonnegative($val); };
check_double(true, $nonnegative, "non-negative", 10);
check_double(true, $nonnegative, "non-negative", 0);
check_double(false, $nonnegative, "non-negative", -10);

$nonpositive = function ($val) { test_nonpositive($val); };
check_double(false, $nonpositive, "non-positive", 10);
check_double(true, $nonpositive, "non-positive", 0);
check_double(true, $nonpositive, "non-positive", -10);

$positive = function ($val) { test_positive($val); };
check_double(true, $positive, "positive", 10);
check_double(false, $positive, "positive", 0);
check_double(false, $positive, "positive", -10);

$negative = function ($val) { test_negative($val); };
check_double(false, $negative, "negative", 10);
check_double(false, $negative, "negative", 0);
check_double(true, $negative, "negative", -10);

$nonzero = function ($val) { test_nonzero($val); };
check_double(true, $nonzero, "nonzero", 10);
check_double(false, $nonzero, "nonzero", 0);
check_double(true, $nonzero, "nonzero", -10);

$have_exception = false;
try {
  test_nonnull(null);
} catch(ValueError $e) {
  $msg = $e->getMessage();
  $have_exception = strcmp($msg, "Received a NULL pointer.") === 0;
}
if (!$have_exception) {
    throw new Exception("test_nonnull should perform a proper exception with 'null' value");
}

$non_null = get_nonnull();
test_nonnull($non_null);
