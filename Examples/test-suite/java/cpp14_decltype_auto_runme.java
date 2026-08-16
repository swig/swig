import cpp14_decltype_auto.*;

public class cpp14_decltype_auto_runme {

  static {
    try {
      System.loadLibrary("cpp14_decltype_auto");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. " + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // 'decltype(auto)' deduces from the initialiser, as 'auto' does.
    if (cpp14_decltype_auto.getVar_int() != 42)
      throw new RuntimeException("var_int");
    if (cpp14_decltype_auto.getVar_const() != 7)
      throw new RuntimeException("var_const");

    // A parenthesised name deduces a reference to what it names, so writing the variable writes the original.
    cpp14_decltype_auto.setVar_paren_int(10);
    if (cpp14_decltype_auto.getParen_int() != 10)
      throw new RuntimeException("var_paren_int should refer to paren_int");
    if (cpp14_decltype_auto.paren_deref(cpp14_decltype_auto.getVar_paren_ptr()) != 10)
      throw new RuntimeException("var_paren_ptr should refer to paren_ptr");

    // Unlike 'auto', 'decltype(auto)' keeps the reference, so var_ref is wrapped as 'int &' and
    // reaches Java as a pointer type where var_int gives a plain int.
    if (cpp14_decltype_auto.getVar_ref() == null)
      throw new RuntimeException("var_ref");
    try {
      if (cpp14_decltype_auto.class.getMethod("getVar_ref").getReturnType() != SWIGTYPE_p_int.class)
        throw new RuntimeException("var_ref should keep the reference");
      if (cpp14_decltype_auto.class.getMethod("getVar_int").getReturnType() != int.class)
        throw new RuntimeException("var_int should be a plain int");
    } catch (NoSuchMethodException e) {
      throw new RuntimeException("missing variable accessor", e);
    }

    Klass k = new Klass(11);
    if (k.plain() != 11)
      throw new RuntimeException("plain()");

    // A deduced return type is not deduced from the body, so these are ignored.
    try {
      cpp14_decltype_auto.class.getMethod("ret_plain");
      throw new RuntimeException("ret_plain should be ignored (deduced return type)");
    } catch (NoSuchMethodException expected) {
    }
    try {
      Klass.class.getMethod("mem");
      throw new RuntimeException("Klass::mem should be ignored (deduced return type)");
    } catch (NoSuchMethodException expected) {
    }
  }
}
