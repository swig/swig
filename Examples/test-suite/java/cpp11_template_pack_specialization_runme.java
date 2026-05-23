import cpp11_template_pack_specialization.*;

public class cpp11_template_pack_specialization_runme {
  static {
    try {
      System.loadLibrary("cpp11_template_pack_specialization");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String args[]) {
    SomeParmsInt spi = new SomeParmsInt();
    spi.primary_method();

    SomeParmsNoParms spp = new SomeParmsNoParms();
    spp.partial_method();

    SomeParmsString sps = new SomeParmsString();
    sps.partial_method("hello");

    SomeParmsIntDouble spid = new SomeParmsIntDouble();
    spid.partial_method(10, 11.1);

    SomeParms2PackInt sp2i = new SomeParms2PackInt();
    sp2i.partial2_methodC(20);

    SomeParms2PackIntDouble sp2id = new SomeParms2PackIntDouble();
    sp2id.partial2_methodA(11.1);
    sp2id.partial2_methodB(55, 11.1);
    sp2id.partial2_methodC(55);

    SomeParms2PackIntDoubleFloat sp2idf = new SomeParms2PackIntDoubleFloat();
    sp2idf.partial2_methodA(11.1, 22.2f);
    sp2idf.partial2_methodB(55, 11.1, 22.2f);
    sp2idf.partial2_methodC(55);

    // StdFunction testing
    StdFunctionIntInt f_int = new StdFunctionIntInt();
    check(f_int.call(10, 20), 30, "f_int.call(10, 20)");
    check(f_int.call_operator(20, 30), 50, "f_int.call_operator(20, 30)");

    StdFunctionVoid f_int0 = new StdFunctionVoid();
    check(f_int0.call(), 0, "f_int0.call()");
    check(f_int0.call_operator(), 0, "f_int0.call_operator()");

    StdFunctionInt f_int1 = new StdFunctionInt();
    check(f_int1.call(7), 7, "f_int1.call(7)");
    check(f_int1.call_operator(7), 7, "f_int1.call_operator(7)");

    StdFunctionDoubleDouble f_double = new StdFunctionDoubleDouble();
    check(f_double.call(1.5, 2.25), 3.75, "f_double.call(1.5, 2.25)");
    check(f_double.call_operator(1.5, 2.25), 3.75, "f_double.call_operator(1.5, 2.25)");

    StdFunctionStringString f_string = new StdFunctionStringString();
    check(f_string.call("ab", "cd"), "abcd", "f_string.call(\"ab\", \"cd\")");
    check(f_string.call_operator("ab", "cd"), "abcd", "f_string.call_operator(\"ab\", \"cd\")");

    StdFunctionMixed f_mixed = new StdFunctionMixed();
    check(f_mixed.call(1, 2.0, 3), 6, "f_mixed.call(1, 2.0, 3)");
    check(f_mixed.call_operator(1, 2.0, 3), 6, "f_mixed.call_operator(1, 2.0, 3)");
  }

  static void check(int actual, int expected, String label) {
    if (actual != expected)
      throw new RuntimeException(label + " expected " + expected + " got " + actual);
  }

  static void check(double actual, double expected, String label) {
    if (actual != expected)
      throw new RuntimeException(label + " expected " + expected + " got " + actual);
  }

  static void check(String actual, String expected, String label) {
    if (!actual.equals(expected))
      throw new RuntimeException(label + " expected " + expected + " got " + actual);
  }
}
