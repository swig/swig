<?php

require "tests.php";

function check_type_error($name, $f) {
  try {
    $f();
    check::fail("$name accepted");
  } catch (TypeError $e) {
  }
}

$s = new Square(10);
check::equal(100.0, member_pointer::do_op($s, member_pointer::areapt()), "Square area");
check::equal(40.0, member_pointer::do_op($s, member_pointer::perimeterpt()), "Square perim");

# Overloaded on the member pointer type
check::equal(3, member_pointer::call_overloaded(member_pointer::addbyvaluept(), 1, 2), "Overload by value");
check::equal(-7, member_pointer::call_overloaded(member_pointer::addbypointerpt(), 3, 4), "Overload by pointer");
check::equal(110, member_pointer::call_overloaded(10, 5, 6), "Overload by int");

# A member pointer of another type, an object that is not a member pointer or null is not accepted
check_type_error("do_op with addbyvaluept", fn() => member_pointer::do_op($s, member_pointer::addbyvaluept()));
check_type_error("do_op with a Square", fn() => member_pointer::do_op($s, $s));
check_type_error("do_op with null", fn() => member_pointer::do_op($s, null));

check::done();
