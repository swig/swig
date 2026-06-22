import cpp17_using_typename_pack.*;

public class cpp17_using_typename_pack_runme {
  static {
    try {
        System.loadLibrary("cpp17_using_typename_pack");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  static void check(int got, int expected) {
    if (got != expected)
      throw new RuntimeException("Expected " + expected + " but got " + got);
  }

  public static void main(String argv[])
  {
    CollectorInt c = new CollectorInt();
    check(c.zero(), 0);   // value_type() == int() == 0
    check(c.echo(42), 42);
  }
}
