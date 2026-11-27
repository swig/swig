<?php

require "tests.php";

function check_type_error($name, $f) {
  try {
    $f();
    check::fail("$name accepted");
  } catch (TypeError $e) {
  }
}

$m = new MemberFuncPtrs();
check::equal($m->aaa1(cc1_get()), 0, "aaa1");
check::equal($m->aaa6(cc6_get()), 0, "aaa6");
check::equal($m->aaa7(cc7_get()), 0, "aaa7");
check::equal($m->bbb1(pp1_get()), 0, "bbb1");
check::equal($m->bbb6(pp6_get()), 0, "bbb6");
check::equal($m->bbb7(pp7_get()), 0, "bbb7");
check::equal(call1(ADD_BY_VALUE, 1, 2), 3, "call1");

# A pointer to a non-const member function is not a pointer to a const member function, nor the reverse
check_type_error("aaa1 with pp1", fn() => $m->aaa1(pp1_get()));
check_type_error("aaa7 with pp7", fn() => $m->aaa7(pp7_get()));
check_type_error("bbb1 with cc1", fn() => $m->bbb1(cc1_get()));
check_type_error("bbb7 with cc7", fn() => $m->bbb7(cc7_get()));

check::done();
