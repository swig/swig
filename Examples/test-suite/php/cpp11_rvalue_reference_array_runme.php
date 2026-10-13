<?php

require "tests.php";

function check_null_rejected($name, $f) {
  try {
    $f();
    check::fail("$name accepted null");
  } catch (TypeError $e) {
  }
}

// An rvalue reference to an array is passed as a reference to an array, which cannot be null.
check::equal(sum_of(others_address()), 100, "sum_of");
check::equal(first_of(others_unsized_address()), 10, "first_of");
check::equal(items_sum(items_address()), 3, "items_sum");
check_null_rejected("sum_of", fn() => sum_of(null));
check_null_rejected("first_of", fn() => first_of(null));

// An rvalue reference to an array of char is a string.
check::equal(length_of("abc"), 3, "length_of");
check::equal(length_of_writable("xy"), 2, "length_of_writable");
check_null_rejected("length_of", fn() => length_of(null));

// Setting a variable that is an rvalue reference to an array copies into the array it refers to.
check::equal(numbers_sum(), 10, "numbers_sum");
check::set("numbers_rref", others_address());
check::equal(numbers_sum(), 100, "numbers_sum after set");
check::equal(check::get("letters_rref"), "abc", "letters_rref");
check::set("letters_rref", "xy");
check::equal(letters_are(), "xy", "letters_are");

$member = new RvalueRefArrayMember();
check::equal($member->sum(), 10, "member sum");
$member->member_rref = others_address();
check::equal($member->sum(), 100, "member sum after set");
check::equal($member->text_rref, "hi", "member text_rref");
$member->text_rref = "bye";
check::equal($member->text_is(), "bye", "member text_is");

check::done();
