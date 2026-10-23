import cpp11_alias_template_inheritance.*;

public class cpp11_alias_template_inheritance_runme {
  static {
    try {
        System.loadLibrary("cpp11_alias_template_inheritance");
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
    // Member imported through the identity alias template base 'XIdentity<X>'.
    check(new DerivedX().m(), 11);

    // Inherited enum imported through the identity alias template base 'PaletteIdentity<Palette>', and
    // the alias used as a function parameter type.  The enumerators wrap as Palette.Color constants.
    check(Palette.Color.RED.swigValue(), 0);
    check(Palette.Color.GREEN.swigValue(), 1);
    check(Palette.Color.BLUE.swigValue(), 2);
    check(cpp11_alias_template_inheritance.palette_to_int(Palette.Color.GREEN), 1);

    // Overload imported through the alias template base 'AdderAlias<int>' merges with the local overload.
    AliasCalcInt ac = new AliasCalcInt();
    check(ac.add(5), 105);    // local single-arg overload
    check(ac.add(2, 3), 5);   // imported two-arg overload via using through the alias template

    // Inherited constructor reached through the identity alias template base 'BaseCIdentity<BaseC>'.
    check(new DerivedC(42).getValue(), 42);
  }
}
