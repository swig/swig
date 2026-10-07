<?php

require "tests.php";

// No new functions
check::functions(array());
check::classes(array('CharArrayDirector'));
// No new vars
check::globals(array());

class Director extends CharArrayDirector {
  function take_array(string $s) { return strlen($s); }
  function take_const_array(string $s) { return strlen($s); }
  function take_array_ref(string $s) { return strlen($s); }
  function take_const_array_ref(string $s) { return strlen($s); }
  function is_null_array(?string $s) { return $s === null ? 1 : 0; }
}

$d = new Director();
check::equal($d->call_take_array(), 4, "take_array");
check::equal($d->call_take_const_array(), 4, "take_const_array");
check::equal($d->call_take_array_ref(), 4, "take_array_ref");
check::equal($d->call_take_const_array_ref(), 4, "take_const_array_ref");
check::equal($d->call_take_array_short(), 2, "take_array short");
check::equal($d->call_take_array_ref_short(), 2, "take_array_ref short");
check::equal($d->call_is_null_array(), 1, "is_null_array");

check::done();
