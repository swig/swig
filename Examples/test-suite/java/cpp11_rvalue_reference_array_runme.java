import cpp11_rvalue_reference_array.*;

public class cpp11_rvalue_reference_array_runme {
  static {
    try {
        System.loadLibrary("cpp11_rvalue_reference_array");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[])
  {
    // An rvalue reference to an array is passed as a reference to an array, which cannot be null.
    check(100, cpp11_rvalue_reference_array.sum_of(cpp11_rvalue_reference_array.others_address()));
    check(10, cpp11_rvalue_reference_array.first_of(cpp11_rvalue_reference_array.others_unsized_address()));
    check(3, cpp11_rvalue_reference_array.items_sum(cpp11_rvalue_reference_array.items_address()));
    try {
      cpp11_rvalue_reference_array.sum_of(null);
      throw new RuntimeException("sum_of(null) did not throw");
    } catch (NullPointerException e) {
    }
    try {
      cpp11_rvalue_reference_array.first_of(null);
      throw new RuntimeException("first_of(null) did not throw");
    } catch (NullPointerException e) {
    }

    // An rvalue reference to an array of char is a string.
    check(3, cpp11_rvalue_reference_array.length_of("abc"));
    check(2, cpp11_rvalue_reference_array.length_of_writable("xy"));
    try {
      cpp11_rvalue_reference_array.length_of(null);
      throw new RuntimeException("length_of(null) did not throw");
    } catch (NullPointerException e) {
    }

    // Setting a variable that is an rvalue reference to an array copies into the array it refers to.
    check(10, cpp11_rvalue_reference_array.numbers_sum());
    cpp11_rvalue_reference_array.setNumbers_rref(cpp11_rvalue_reference_array.others_address());
    check(100, cpp11_rvalue_reference_array.numbers_sum());
    check("abc", cpp11_rvalue_reference_array.getLetters_rref());
    cpp11_rvalue_reference_array.setLetters_rref("xy");
    check("xy", cpp11_rvalue_reference_array.letters_are());

    RvalueRefArrayMember member = new RvalueRefArrayMember();
    check(10, member.sum());
    member.setMember_rref(cpp11_rvalue_reference_array.others_address());
    check(100, member.sum());
    check("hi", member.getText_rref());
    member.setText_rref("bye");
    check("bye", member.text_is());
  }

  static void check(int expected, int actual) {
    if (expected != actual)
      throw new RuntimeException("expected " + expected + " but got " + actual);
  }

  static void check(String expected, String actual) {
    if (!expected.equals(actual))
      throw new RuntimeException("expected " + expected + " but got " + actual);
  }
}
