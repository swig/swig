using System;
using cpp11_rvalue_reference_arrayNamespace;

public class cpp11_rvalue_reference_array_runme {

  public static void Main() {
    // An rvalue reference to an array is passed as a reference to an array, which cannot be null.
    check(100, cpp11_rvalue_reference_array.sum_of(cpp11_rvalue_reference_array.others_address()));
    check(10, cpp11_rvalue_reference_array.first_of(cpp11_rvalue_reference_array.others_unsized_address()));
    check(3, cpp11_rvalue_reference_array.items_sum(cpp11_rvalue_reference_array.items_address()));
    try {
      cpp11_rvalue_reference_array.sum_of(null);
      throw new Exception("sum_of(null) did not throw");
    } catch (ArgumentNullException) {
    }
    try {
      cpp11_rvalue_reference_array.first_of(null);
      throw new Exception("first_of(null) did not throw");
    } catch (ArgumentNullException) {
    }

    // An rvalue reference to an array of char is a string.
    check(3, cpp11_rvalue_reference_array.length_of("abc"));
    check(2, cpp11_rvalue_reference_array.length_of_writable("xy"));
    try {
      cpp11_rvalue_reference_array.length_of(null);
      throw new Exception("length_of(null) did not throw");
    } catch (ArgumentNullException) {
    }

    // Setting a variable that is an rvalue reference to an array copies into the array it refers to.
    check(10, cpp11_rvalue_reference_array.numbers_sum());
    cpp11_rvalue_reference_array.numbers_rref = cpp11_rvalue_reference_array.others_address();
    check(100, cpp11_rvalue_reference_array.numbers_sum());
    check("abc", cpp11_rvalue_reference_array.letters_rref);
    cpp11_rvalue_reference_array.letters_rref = "xy";
    check("xy", cpp11_rvalue_reference_array.letters_are());

    RvalueRefArrayMember member = new RvalueRefArrayMember();
    check(10, member.sum());
    member.member_rref = cpp11_rvalue_reference_array.others_address();
    check(100, member.sum());
    check("hi", member.text_rref);
    member.text_rref = "bye";
    check("bye", member.text_is());
  }

  private static void check(int expected, int actual) {
    if (expected != actual)
      throw new Exception("expected " + expected + " but got " + actual);
  }

  private static void check(string expected, string actual) {
    if (expected != actual)
      throw new Exception("expected " + expected + " but got " + actual);
  }
}
