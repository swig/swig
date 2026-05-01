<?php

require "tests.php";

$fn = pass_checker(420);

// invoke functor via call method
if (!$fn->call(420, "Petka"))
  check::fail("Petka 420 should be true");

if ($fn->call(419, "Chapai"))
  check::fail("Chapai 419 should be false");

// call wrapper
if (!call_function($fn, 420, "Petka"))
  check::fail("Petka 420 should be true");

if (call_function($fn, 419, "Chapai"))
  check::fail("Chapai 419 should be false");

// NULL handling
$passed = false;
try {
  call_function(null, 420, "Petka");
} catch (TypeError $e) {
  $passed = true;
}
if (!$passed)
  check::fail("call_function accepted invalid argument");

// Invalid argument
$passed = false;
try {
  call_function("invalid", 420, "Petka");
} catch (TypeError $e) {
  $passed = true;
}
if (!$passed)
  check::fail("call_function accepted invalid argument");

check::done();
