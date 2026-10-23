module cpp11_rvalue_reference_array_runme;

import std.exception;
import cpp11_rvalue_reference_array.cpp11_rvalue_reference_array;
import cpp11_rvalue_reference_array.RvalueRefArrayMember;

void main() {
  // An rvalue reference to an array is passed as a reference to an array, which cannot be null.
  enforce(sum_of(others_address()) == 100, "sum_of");
  enforce(first_of(others_unsized_address()) == 10, "first_of");
  enforce(items_sum(items_address()) == 3, "items_sum");
  enforce(collectException(sum_of(null)) !is null, "sum_of(null) did not throw");
  enforce(collectException(first_of(null)) !is null, "first_of(null) did not throw");

  // An rvalue reference to an array of char is a string.
  enforce(length_of("abc") == 3, "length_of");
  enforce(length_of_writable("xy") == 2, "length_of_writable");
  enforce(collectException(length_of(null)) !is null, "length_of(null) did not throw");

  // Setting a variable that is an rvalue reference to an array copies into the array it refers to.
  enforce(numbers_sum() == 10, "numbers_sum");
  numbers_rref = others_address();
  enforce(numbers_sum() == 100, "numbers_sum after set");
  enforce(letters_rref == "abc", "letters_rref");
  letters_rref = "xy";
  enforce(letters_are() == "xy", "letters_are");

  auto member = new RvalueRefArrayMember();
  enforce(member.sum() == 10, "member sum");
  member.member_rref = others_address();
  enforce(member.sum() == 100, "member sum after set");
  enforce(member.text_rref == "hi", "member text_rref");
  member.text_rref = "bye";
  enforce(member.text_is() == "bye", "member text_is");
}
