
import cpp11_template_using_base.*;

public class cpp11_template_using_base_runme {

  static {
    try {
        System.loadLibrary("cpp11_template_using_base");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void check(String actual, String expected) {
    if (!actual.equals(expected))
      throw new RuntimeException("expected '" + expected + "' but got '" + actual + "'");
  }

  public static void main(String argv[]) {
    DerivedInt d = new DerivedInt();
    check(d.call(7), "Int:7");

    // Inheriting constructor: using I::I; brings IntCase(int) into DerivedInt
    DerivedInt d10 = new DerivedInt(10);
    check(d10.call(7), "Int:17");

    OverloadedIntDouble o = new OverloadedIntDouble();
    check(o.call(7), "Int:7");
    check(o.call(7.5), "Double:7.500000");
  }
}
