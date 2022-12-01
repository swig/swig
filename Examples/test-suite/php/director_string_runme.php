<?php

require "tests.php";

// No new functions
check::functions(array());
// New classes
check::classes(array('A','StringVector'));
// No new vars
check::globals(array());

class B extends A {
  public $smem;

  function get_first() {
    return parent::get_first() . " world!";
  }

  function process_text($string) {
    parent::process_text($string);
    $this->smem = "hello";
  }
}

$b = new B("hello");

$b->get(0);
check::equal($b->get_first(),"hello world!", "get_first failed");

$b->call_process_func();

check::equal($b->smem, "hello", "smem failed");

check::done();
