import using_member_typedef_overload.*;

public class using_member_typedef_overload_runme {
  static {
    try {
        System.loadLibrary("using_member_typedef_overload");
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
    // Overload imported through the typedef-to-template-instantiation qualifier merges with the local one.
    CalcInt c = new CalcInt();
    check(c.add(5), 105);     // local single-arg overload
    check(c.add(2, 3), 5);    // imported two-arg overload via using through the typedef

    // Unscoped enum inherited via a using-declaration whose qualifier is a typedef for the base; the
    // enumerators wrap as Colours.Color constants, and the typedef names a function parameter.
    check(Colours.Color.RED.swigValue(), 0);
    check(Colours.Color.GREEN.swigValue(), 1);
    check(Colours.Color.BLUE.swigValue(), 2);
    check(using_member_typedef_overload.to_int(Colours.Color.GREEN), 1);
    check(using_member_typedef_overload.to_int(Colours.Color.BLUE), 2);
  }
}
