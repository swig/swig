<?php
// This is the long_long runtime testcase. It checks that the long long and
// unsigned long long types map correctly to PHP int or string (for values
// which don't fit in a PHP int).

require "tests.php";

check::functions(array("foo1","foo2","foo3","foo4","foo5","foo6","bar1","bar2","bar3","bar4","bar5","bar6","UnsignedToSigned"));
check::classes(array("long_long"));
check::globals(array("ll","ull"));

function check_ll($ll) {
  long_long::ll_set($ll);
  check::equivalent($ll, long_long::ll_get(), "Round tripping of long long failed");
}

function check_ull($ull) {
  long_long::ull_set($ull);
  check::equivalent($ull, long_long::ull_get(), "Round tripping of unsigned long long failed");
}

check_ll("0");
check_ll(0);
check_ll("9223372036854775807"); // 0x7FFFFFFFFFFFFFFF
if ((int)0x100000000 !== 0) {
  // This check doesn't work if PHP int is 32 bits.
  check_ll(0x7FFFFFFFFFFFFFFF);
}
check_ll(-10);

$testNumber = 0;
const COUNT = 1025;

for ($i=0; $i<COUNT; $i++) {
  check_ull($testNumber);
  $testNumber += 1;
}

$testNumber = 256*256/2-COUNT;
for ($i=0; $i<COUNT*2; $i++) {
  check_ull($testNumber);
  $testNumber += 1;
}

$testNumber = 256*256-COUNT;
for ($i=0; $i<COUNT*2; $i++) {
  check_ull($testNumber);
  $testNumber += 1;
}

$testNumber = 0x7FFFFFFFFFFFFFFF-COUNT;
for ($i=0; $i<COUNT*2; $i++) {
  check_ull($testNumber);
  $testNumber += 1;
}

// Check that conversion from unsigned long long to long long gives expected
// value (including negative numbers)

check::equal(long_long::UnsignedToSigned(0), 0, "UnsignedToSigned test failed");
check::equal(long_long::UnsignedToSigned(0xff), 0xff, "UnsignedToSigned test failed");
check::equal(long_long::UnsignedToSigned(-0xff), -0xff, "UnsignedToSigned test failed");
check::equal(long_long::UnsignedToSigned(-1), -1, "UnsignedToSigned test failed");

check::done();
