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
    if (cpp14_decltype_auto.getVar_paren_typedef_ref() != 10)
      throw new RuntimeException("var_paren_typedef_ref should refer to paren_int");

    // A parenthesised address is the pointer itself.
    if (cpp14_decltype_auto.paren_address_value(cpp14_decltype_auto.getVar_paren_address()) != 10)
      throw new RuntimeException("var_paren_address should point to paren_int");

    // A parenthesised enumerator deduces its enumeration.
    if (cpp14_decltype_auto.getVar_paren_scoped() != ParenScoped.scoped_dark)
      throw new RuntimeException("var_paren_scoped");

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

    // A string literal deduces a reference to the array of characters it is, which is wrapped as
    // the string that array is wrapped as.  A wide literal has no string wrapping.
    if (!cpp14_decltype_auto.getVar_string().equals("text"))
      throw new RuntimeException("var_string");
    if (!cpp14_decltype_auto.getVar_string_raw().equals("text"))
      throw new RuntimeException("var_string_raw");
    if (!cpp14_decltype_auto.getVar_string_concat().equals("text"))
      throw new RuntimeException("var_string_concat");
    if (!cpp14_decltype_auto.getVar_string_parens().equals("text"))
      throw new RuntimeException("var_string_parens");
    if (cpp14_decltype_auto.getVar_string_wide() == null)
      throw new RuntimeException("var_string_wide");

    // A cast of a string literal is not a literal, so this 'const char *' can be set to a longer string.
    if (!cpp14_decltype_auto.getVar_string_cast().equals("text"))
      throw new RuntimeException("var_string_cast");
    cpp14_decltype_auto.setVar_string_cast("longer text");
    if (!cpp14_decltype_auto.getVar_string_cast().equals("longer text"))
      throw new RuntimeException("var_string_cast should be settable");

    // A u8, u or U literal is of a character type SWIG has no type for, so it is ignored.
    try {
      cpp14_decltype_auto.class.getMethod("getVar_string_char16");
      throw new RuntimeException("var_string_char16 should be ignored (unsupported character type)");
    } catch (NoSuchMethodException expected) {
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

    // A new-expression deduces the pointer it gives.
    if (cpp14_decltype_auto.new_int_value(cpp14_decltype_auto.getVar_new()) != 5)
      throw new RuntimeException("var_new");
    if (cpp14_decltype_auto.new_klass_value(cpp14_decltype_auto.getVar_new_klass()) != 3)
      throw new RuntimeException("var_new_klass");
  }
}
