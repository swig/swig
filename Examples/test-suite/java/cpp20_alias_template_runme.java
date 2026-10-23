import cpp20_alias_template.*;

public class cpp20_alias_template_runme {

  static {
    try {
      System.loadLibrary("cpp20_alias_template");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  static void check(BoxInt b, int expected, String tag) {
    if (b.get() != expected)
      throw new RuntimeException(tag + ".get() != " + expected);
  }

  public static void main(String argv[]) {
    // All four aliases resolve to Box<int> = BoxInt in the type system.
    BoxInt plain  = cpp20_alias_template.make_plain(10);
    BoxInt num    = cpp20_alias_template.make_num(10);
    BoxInt req    = cpp20_alias_template.make_req(10);
    BoxInt unseen = cpp20_alias_template.make_unseen(10);

    check(plain,  10, "plain");
    check(num,    10, "num");
    check(req,    10, "req");
    check(unseen, 10, "unseen");

    plain.set(42);  check(plain,  42, "plain");
    num.set(42);    check(num,    42, "num");
    req.set(42);    check(req,    42, "req");
    unseen.set(42); check(unseen, 42, "unseen");
  }
}
