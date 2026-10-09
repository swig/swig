import cpp11_template_function_overload_kind.*;

public class cpp11_template_function_overload_kind_runme {

  static {
    try {
      System.loadLibrary("cpp11_template_function_overload_kind");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void check(int got, int expected, String what) {
    if (got != expected)
      throw new RuntimeException(what + " returned " + got + ", expected " + expected);
  }

  public static void main(String argv[]) {
    check(cpp11_template_function_overload_kind.dflt_int(1), 1, "dflt_int(1)");
    check(cpp11_template_function_overload_kind.dflt_int(1, 2), 2, "dflt_int(1, 2)");
    check(cpp11_template_function_overload_kind.value_default_int(1), 3, "value_default_int");
    check(cpp11_template_function_overload_kind.value_default_int_4(1), 4, "value_default_int_4");
    check(new DefaultHolderInt().convert_double(2.5), 2, "convert_double");

    check(cpp11_template_function_overload_kind.pack_types(), 12, "pack_types");
    check(cpp11_template_function_overload_kind.pack_values(), 23, "pack_values");

    check(cpp11_template_function_overload_kind.mixed_type_first(), 32, "mixed_type_first");
    check(cpp11_template_function_overload_kind.mixed_value_first(), 43, "mixed_value_first");
  }
}
