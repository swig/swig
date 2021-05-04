<?php

require "tests.php";

// New functions
check::functions(array('deleteFoo','getStatus','launder','resetStatus'));
// New classes
check::classes(array('director_finalizer','Foo'));
// No new vars
check::globals(array());

class MyFoo extends Foo {
  function __destruct() {
    # It's not safe to call methods on the C++ object from the PHP destructor
    # if the object has been disowned, since the C++ object will already have
    # been destroyed by the time the PHP destructor runs.
    if ($this->thisown) {
      $this->orStatus(2);
    }
    if (method_exists(get_parent_class(), "__destruct")) {
      parent::__destruct();
    }
  }
}

resetStatus();

$a = new MyFoo();
unset($a);

check::equal(getStatus(), 3, "getStatus() failed #1");

resetStatus();

$a = new MyFoo();
launder($a);

check::equal(getStatus(), 0, "getStatus() failed #2");

unset($a);

check::equal(getStatus(), 3, "getStatus() failed #3");

resetStatus();

$a = new MyFoo();
$a->thisown = 0;
check::equal(getStatus(), 0, "shadow release does not fire destructor of disowned object");

deleteFoo($a);
unset($a);

# getStatus() would ideally return 3 here.
check::equal(getStatus(), 1, "getStatus() failed #4");

resetStatus();

$a = new MyFoo();
$a->thisown = 0;
$g = launder($a);
unset($a);
deleteFoo($g);
# getStatus() would ideally return 3 here.
check::equal(getStatus(), 1, "getStatus() failed #5");

resetStatus();

check::done();
