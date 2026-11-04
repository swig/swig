import template_function_overload_kind.*;

public class template_function_overload_kind_runme {

  static {
    try {
      System.loadLibrary("template_function_overload_kind");
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
    check(template_function_overload_kind.kind_int(), 1, "kind_int");
    check(template_function_overload_kind.kind_real(), 1, "kind_real");
    check(template_function_overload_kind.kind_5(), 2, "kind_5");
    check(template_function_overload_kind.kind_constant(), 2, "kind_constant");
    check(template_function_overload_kind.kind_red(), 2, "kind_red");
    check(template_function_overload_kind.kind_int_double(), 3, "kind_int_double");
    check(template_function_overload_kind.kind_box(), 4, "kind_box");

    if (template_function_overload_kind.kindp_double(1.5) != 1.5)
      throw new RuntimeException("kindp_double");
    check(template_function_overload_kind.kindp_10(1), 11, "kindp_10");

    check(template_function_overload_kind.kindsize_3(), 3, "kindsize_3");
    check(template_function_overload_kind.kindvalue_int_7(), 7, "kindvalue_int_7");

    KindMember m = new KindMember();
    check(m.get_int(), 1, "get_int");
    check(m.get_7(), 2, "get_7");
  }
}
