<?php

require "tests.php";

# Fails in a ZTS-build of PHP5 - see: https://github.com/swig/swig/pull/155
# FIXME: Does this still fail in a threaded build of PHP7?
exit(0);

// New functions
check::functions(array('millisecondsleep','foo_stop','foo_run','foo_do_foo'));
// New classes
check::classes(array('director_thread','Foo'));
// No new vars
check::globals(array());

class Derived extends Foo {
  function do_foo() {
    $this->val = $this->val - 1;
  }
}

$d = new Derived();
$d->run();

if ($d->val >= 0) {
  check::fail($d->val);
}

$d->stop();

check::done();
