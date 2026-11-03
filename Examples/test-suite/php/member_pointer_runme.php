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

# Try the constants
check::equal(100.0, member_pointer::do_op($s, AREAPT), "Square area");
check::equal(40.0, member_pointer::do_op($s, PERIMPT), "Square perim");
check::equal(true, member_pointer::is_null_memberpt(NULLPT), "NULLPT");
check::equal(3, member_pointer::call1(ADD_BY_VALUE, 1, 2), "Add by value");
check::equal(7, member_pointer::call2(ADD_BY_POINTER, 3, 4), "Add by pointer");
check::equal(11, member_pointer::call3(ADD_BY_REFERENCE, 5, 6), "Add by reference");

# Const references to member pointers
check::equal(100.0, member_pointer::do_op_cref($s, member_pointer::areapt()), "Square area");
check::equal(40.0, member_pointer::do_op_cref($s, member_pointer::perimetervar_td_cref()), "Square perim");
check::equal(40.0, member_pointer::do_op($s, member_pointer::perimetervar_td_cref()), "Square perim");

# Overloaded on the member pointer type
check::equal(3, member_pointer::call_overloaded(member_pointer::addbyvaluept(), 1, 2), "Overload by value");
check::equal(-7, member_pointer::call_overloaded(member_pointer::addbypointerpt(), 3, 4), "Overload by pointer");
check::equal(110, member_pointer::call_overloaded(10, 5, 6), "Overload by int");

# A member pointer of another type, an object that is not a member pointer or null is not accepted
check_type_error("do_op with addbyvaluept", fn() => member_pointer::do_op($s, member_pointer::addbyvaluept()));
check_type_error("do_op with a Square", fn() => member_pointer::do_op($s, $s));
check_type_error("do_op with null", fn() => member_pointer::do_op($s, null));

# The type declared for a member pointer parameter or return value is the class of the member pointer
$c = get_class(member_pointer::areapt());
$p = (new ReflectionFunction('do_op'))->getParameters();
check::equal((string)$p[1]->getType(), $c, "do_op member pointer parameter type");
check::equal((string)(new ReflectionFunction('areapt'))->getReturnType(), $c, "areapt return type");

check::done();
