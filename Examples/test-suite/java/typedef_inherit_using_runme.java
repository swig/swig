import typedef_inherit_using.*;

public class typedef_inherit_using_runme {
  static {
    try {
        System.loadLibrary("typedef_inherit_using");
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
    check(new Derived().m(), 11);
    check(new Derived().n(7), 7);
    check(new Derived2().m(), 11);
    check(new UsesConv().toInt(), 42);
  }
}
