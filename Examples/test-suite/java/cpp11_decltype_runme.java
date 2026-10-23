import cpp11_decltype.*;

public class cpp11_decltype_runme {

  static {
    try {
      System.loadLibrary("cpp11_decltype");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void check(long got, long expected, String what) {
    if (got != expected)
      throw new RuntimeException(what + " expected: " + expected + " got: " + got);
  }

  public static void main(String argv[]) {
    // A dereference and a subscript are lvalues, so these return 'int &', passed on here as the 'int *' it wraps as.
    check(cpp11_decltype.deref_first(cpp11_decltype.deref_lvalue()), 4, "deref_lvalue");
    check(cpp11_decltype.deref_first(cpp11_decltype.subscript_lvalue()), 5, "subscript_lvalue");
    check(cpp11_decltype.deref_first(cpp11_decltype.parameter_subscript(cpp11_decltype.three_values(), 2)), 33, "parameter_subscript");
    check(cpp11_decltype.subscript_sum(cpp11_decltype.three_values()), 23, "subscript_sum");
    check(cpp11_decltype.deref_first(cpp11_decltype.indexed_element()), 9, "indexed_element");

    // An 'int &' variable is wrapped as a pointer, which sees the element it refers to change.
    check(cpp11_decltype.deref_first(cpp11_decltype.getSubscript_ref()), 20, "subscript_ref");
    cpp11_decltype.set_subscript_value(1, 21);
    check(cpp11_decltype.deref_first(cpp11_decltype.getSubscript_ref()), 21, "subscript_ref after set");
    char literal_element_ref = cpp11_decltype.getLiteral_element_ref();
    check(literal_element_ref, 'b', "literal_element_ref");

    // The template argument is an array type, so the member is an array.
    ArrayHolder3 holder = new ArrayHolder3();
    holder.setHeld(cpp11_decltype.three_values());
    check(cpp11_decltype.deref_first(holder.getHeld()), 11, "ArrayHolder3.held");
    check(ArrayHolder3.count, 3, "ArrayHolder3.count");
  }
}
