import cpp20_abbreviated_template_mixed.*;

public class cpp20_abbreviated_template_mixed_runme {

  static {
    try {
      System.loadLibrary("cpp20_abbreviated_template_mixed");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // Each non-decorated case pairs std::string with a numeric type so an argument order swap is a
    // Java compile error rather than a silent numeric conversion.  Each mix function joins its
    // arguments with '/' between them via a shared join_text helper, so the expected strings show
    // the binding directly.

    // a. Explicit typename + auto.  T=std::string, auto=int.
    if (!cpp20_abbreviated_template_mixed.a_mix_si("hello", 5).equals("hello/5"))
      throw new RuntimeException("a_mix_si");

    // b. Auto + explicit typename.  Template <U=std::string, auto=int> -> wrapped (int, std::string).
    if (!cpp20_abbreviated_template_mixed.b_mix_is(3, "hi").equals("3/hi"))
      throw new RuntimeException("b_mix_is");

    // c. Two explicit parms surrounding an auto.  Template <T=int, V=int, auto=std::string> ->
    // wrapped (int, string, int) per the function parm order.
    if (!cpp20_abbreviated_template_mixed.c_mix_isi(1, "x", 2).equals("1/x/2"))
      throw new RuntimeException("c_mix_isi");

    // d. Constrained explicit + constrained auto.  T=int, auto=double.
    if (!cpp20_abbreviated_template_mixed.d_mix_id(3, 4.0).equals("3/4.00"))
      throw new RuntimeException("d_mix_id");

    // e. Two autos surrounding an explicit typename.  auto=string, T=int, auto=string.
    if (!cpp20_abbreviated_template_mixed.e_mix_iss("a", 7, "b").equals("a/7/b"))
      throw new RuntimeException("e_mix_iss");

    // Cases f..j combine 'auto' with a variadic explicit pack.  Per C++20 [dcl.fct]/19 the invented
    // type template-parameter for each 'auto' is appended after the explicit list, so when that list
    // ends in a pack the invented sits past it.  %template binding is positional: leading non-variadic
    // parms bind one to one, the pack absorbs the middle args, and trailing args bind to the invented
    // parms in declaration order.

    // f. Auto + variadic pack.  Ts={int, std::string}, invented=double.  Pack args wrapped in "[" / "]" markers.
    if (!cpp20_abbreviated_template_mixed.f_mix_isd(2.5, 7, "Y").equals("2.50/[/7/Y/]"))
      throw new RuntimeException("f_mix_isd");

    // g. Leading explicit + auto + variadic pack.  T=int, Ts={std::string, double}, invented=std::string.
    if (!cpp20_abbreviated_template_mixed.g_mix_isds(1, "Y", "Z", 2.5).equals("1/Y/[/Z/2.50/]"))
      throw new RuntimeException("g_mix_isds");

    // h. Constrained auto + variadic pack.  Ts={int, std::string}, invented=double.
    if (!cpp20_abbreviated_template_mixed.h_mix_isd(4.0, 7, "Y").equals("4.00/[/7/Y/]"))
      throw new RuntimeException("h_mix_isd");

    // i. Two autos surrounding a variadic pack.  Ts={int, std::string}, invented1=double, invented2=int.
    if (!cpp20_abbreviated_template_mixed.i_mix_isdi(2.5, 7, "Y2", 99).equals("2.50/[/7/Y2/]/99"))
      throw new RuntimeException("i_mix_isdi");

    // j. Decorated auto (const auto&) + variadic pack.  Ts={int, std::string}, invented=double.
    if (!cpp20_abbreviated_template_mixed.j_mix_isd(2.5, 7, "Y").equals("2.50/[/7/Y/]"))
      throw new RuntimeException("j_mix_isd");
  }
}
