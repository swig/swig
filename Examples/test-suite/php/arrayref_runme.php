<?php

require "tests.php";

// Setting a variable that is a reference to an array copies into the array it refers to.
check::equal(numbers_sum(), 10, "numbers_sum");
check::set("numbers_ref", others_address());
check::equal(numbers_sum(), 100, "numbers_sum after set");

// An array of char is a string here, and so is a reference to one.
check::equal(check::get("letters"), "abc", "letters");
check::equal(check::get("letters_ref"), "abc", "letters_ref");
check::set("letters_ref", "xy");
check::equal(letters_are(), "xy", "letters_are");
check::equal(check::get("frozen_ref"), "xyz", "frozen_ref");

$member = new ArrayRefMember();
check::equal($member->sum(), 10, "member sum");
check::equal($member->text_ref, "hi", "member text_ref");
$member->text_ref = "bye";
check::equal($member->text_is(), "bye", "member text_is");

check::done();
