import cpp11_auto_variable.*;

public class cpp11_auto_variable_runme {

  static {
    try {
      System.loadLibrary("cpp11_auto_variable");
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
    // A subscript deduces the element type, which the Java type of each getter shows.
    int array_element = cpp11_auto_variable.getArray_element();
    check(array_element, 31, "array_element");
    int pointer_element = cpp11_auto_variable.getPointer_element();
    check(pointer_element, 32, "pointer_element");
    check(cpp11_auto_variable.int_ptr_second(cpp11_auto_variable.getMatrix_row()), 44, "matrix_row");
    int matrix_element = cpp11_auto_variable.getMatrix_element();
    check(matrix_element, 45, "matrix_element");
    int typedef_array_element = cpp11_auto_variable.getTypedef_array_element();
    check(typedef_array_element, 7, "typedef_array_element");
    int paren_element = cpp11_auto_variable.getParen_element();
    check(paren_element, 30, "paren_element");
    char literal_element = cpp11_auto_variable.getLiteral_element();
    check(literal_element, 'b', "literal_element");
    double indexed_element = cpp11_auto_variable.getIndexed_element();
    if (indexed_element != 2.5)
      throw new RuntimeException("indexed_element expected: 2.5 got: " + indexed_element);
    check(cpp11_auto_variable.matrix_default(), 41, "matrix_default");

    // The 'int &' variables are wrapped as pointers, which see the elements they refer to change.
    cpp11_auto_variable.set_subscript_array_value(0, 60);
    cpp11_auto_variable.set_subscript_array_value(2, 62);
    check(cpp11_auto_variable.deref_const_int_ptr(cpp11_auto_variable.getElement_ref()), 60, "element_ref");
    check(cpp11_auto_variable.deref_const_int_ptr(cpp11_auto_variable.getForwarded_element()), 62, "forwarded_element");

    // auto drops a reference hidden by a typedef.
    int typedef_ref_element = cpp11_auto_variable.getTypedef_ref_element();
    check(typedef_ref_element, 71, "typedef_ref_element");
    int typedef_ref_copy = cpp11_auto_variable.getTypedef_ref_copy();
    check(typedef_ref_copy, 70, "typedef_ref_copy");
    check(cpp11_auto_variable.deref_const_int_ptr(cpp11_auto_variable.getTypedef_ref_address()), 70, "typedef_ref_address");
    check(cpp11_auto_variable.deref_const_int_ptr(cpp11_auto_variable.getTypedef_ref_forwarded()), 71, "typedef_ref_forwarded");
    check(cpp11_auto_variable.getTypedef_ref_paren(), 70, "typedef_ref_paren");
    if (cpp11_auto_variable.getTypedef_ref_paren_class() == null)
      throw new RuntimeException("typedef_ref_paren_class");
  }
}
