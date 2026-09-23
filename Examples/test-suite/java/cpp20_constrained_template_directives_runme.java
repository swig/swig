import cpp20_constrained_template_directives.*;

public class cpp20_constrained_template_directives_runme {

  static {
    try {
      System.loadLibrary("cpp20_constrained_template_directives");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void check(int got, int expected, String what) {
    if (got != expected)
      throw new RuntimeException(what + " expected: " + expected + " got: " + got);
  }

  private static void checkLastCalled(String expected) {
    String got = cpp20_constrained_template_directives.getLastCalled();
    if (!got.equals(expected))
      throw new RuntimeException("expected: " + expected + " got: " + got);
  }

  public static void main(String argv[]) {
    check(cpp20_constrained_template_directives.prefixed(2.5), 2, "prefixed(2.5)");
    checkLastCalled("prefixed IsReal");

    check(cpp20_constrained_template_directives.trailing(3), 1, "trailing(3)");
    checkLastCalled("trailing IsInt");

    check(cpp20_constrained_template_directives.typed(2.5), 2, "typed(2.5)");
    check(cpp20_constrained_template_directives.mixed(3), 1, "mixed(3)");
    check(cpp20_constrained_template_directives.halved(2.5), 2, "halved(2.5)");
    check(cpp20_constrained_template_directives.spelt(new FiveBytes()), 1, "spelt(FiveBytes)");
    check(cpp20_constrained_template_directives.packed(1.5, 2.5), 2, "packed(1.5, 2.5)");
    check(new Picker().pick(2.5), 2, "Picker.pick(2.5)");
    check(cpp20_constrained_template_directives.plain(3), 1, "plain(3)");
  }
}
