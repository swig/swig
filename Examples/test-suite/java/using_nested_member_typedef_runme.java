import using_nested_member_typedef.*;

public class using_nested_member_typedef_runme {
  static {
    try {
        System.loadLibrary("using_nested_member_typedef");
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
    UsingDerived d = new UsingDerived();
    check(d.hh(81), 81);

    UsingDerivedDeep deep = new UsingDerivedDeep();
    check(deep.jj(81), 81);
  }
}
