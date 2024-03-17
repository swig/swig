<?php

require "tests.php";

// No new functions
check::functions(array());
// New classes
check::classes(array('A'));
// No new vars
check::globals(array());

class B extends A {
  public $smem;

  private $cached_string;

  function get_first() {
    // Since std::string_view contains a pointer into a string, the string
    // cannot be a temporary in order to avoid undefined behaviour.
    $this->cached_string = parent::get_first() . " world!";
    return $this->cached_string;
  }

  function process_text($string) {
    parent::process_text($string);
    $this->smem = "hello";
  }
}

$b = new B("hello");

check::equal($b->get(0), "hello", "get(0) failed");

check::equal($b->get_first(), "hello world!", "get_first failed");

check::equal($b->call_get_first(), "hello world!", "call_get_first failed");

$b->call_process_func();

check::equal($b->smem, "hello", "smem failed");

check::done();
