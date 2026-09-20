import arrayref.*;

public class arrayref_runme {
  static {
    try {
        System.loadLibrary("arrayref");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[])
  {
    // Setting a reference to an array copies the elements into the array it refers to.
    check(10, arrayref.numbers_sum());
    arrayref.setNumbers_ref(arrayref.others_address());
    check(100, arrayref.numbers_sum());

    // Setting a reference to an array of arrays copies every element.
    arrayref.setGrid_ref(arrayref.other_grid_address());
    check(20, arrayref.grid_element(0, 1));
    check(60, arrayref.grid_element(1, 2));

    GridRefMember gridMember = new GridRefMember();
    gridMember.setRows_ref(arrayref.other_grid_address());
    check(20, gridMember.element(0, 1));
    check(60, gridMember.element(1, 2));

    // Setting a reference to an array of pointers copies the pointers.
    PointerRefArrayHolder pointerHolder = new PointerRefArrayHolder();
    pointerHolder.setElements_ref(arrayref.pointers_address());
    if (!arrayref.holds_pointers(pointerHolder))
      throw new RuntimeException("pointers not copied");

    ArrayRefMember member = new ArrayRefMember();
    check(10, member.sum());
    member.setMember_ref(arrayref.others_address());
    check(100, member.sum());

    // An array of char is a string here, and so is a reference to one.
    check("abc", arrayref.getLetters());
    check("abc", arrayref.getLetters_ref());
    arrayref.setLetters_ref("xy");
    check("xy", arrayref.letters_are());
    check("xyz", arrayref.getFrozen_ref());

    // A reference to an array of char cannot be null.
    check(3, arrayref.length_of("abc"));
    check(2, arrayref.length_of_writable("xy"));
    try {
      arrayref.length_of(null);
      throw new RuntimeException("length_of(null) did not throw");
    } catch (NullPointerException e) {
    }
    try {
      arrayref.length_of_writable(null);
      throw new RuntimeException("length_of_writable(null) did not throw");
    } catch (NullPointerException e) {
    }

    check("hi", member.getText_ref());
    member.setText_ref("bye");
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
