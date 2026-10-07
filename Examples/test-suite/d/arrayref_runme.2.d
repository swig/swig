module arrayref_runme;

import std.exception;
import arrayref.arrayref;
import arrayref.ArrayRefMember;

void main() {
  // Setting a variable that is a reference to an array copies into the array it refers to.
  enforce(numbers_sum() == 10, "numbers_sum");
  numbers_ref = others_address();
  enforce(numbers_sum() == 100, "numbers_sum after set");

  // An array of char is a string here, and so is a reference to one.
  enforce(letters == "abc", "letters");
  enforce(letters_ref == "abc", "letters_ref");
  letters_ref = "xy";
  enforce(letters_are() == "xy", "letters_are");
  enforce(frozen_ref == "xyz", "frozen_ref");

  // A reference to an array of char cannot be null.
  enforce(length_of("abc") == 3, "length_of");
  enforce(length_of_writable("xy") == 2, "length_of_writable");
  enforce(collectException(length_of(null)) !is null, "length_of(null) did not throw");
  enforce(collectException(length_of_writable(null)) !is null, "length_of_writable(null) did not throw");

  auto member = new ArrayRefMember();
  enforce(member.sum() == 10, "member sum");
  enforce(member.text_ref == "hi", "member text_ref");
  member.text_ref = "bye";
  enforce(member.text_is() == "bye", "member text_is");
}
