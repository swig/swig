
import cpp11_inheriting_constructors_typedef.*;

public class cpp11_inheriting_constructors_typedef_runme {

  static {
    try {
        System.loadLibrary("cpp11_inheriting_constructors_typedef");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void check(int actual, int expected) {
    if (actual != expected)
      throw new RuntimeException("expected " + expected + " but got " + actual);
  }

  public static void main(String argv[]) {
    // Plain non-template base via a plain typedef: overloaded constructor and a method through the typedef
    check(new PlainTypedefBase(7).value(), 7);
    check(new PlainTypedefBase(3, 4).value(), 7);

    // Two typedef'd bases, an inheriting-constructor using-declaration from each
    MultiTypedefBases a = new MultiTypedefBases(5);
    check(a.alpha(), 5);
    check(a.beta(), 0);
    MultiTypedefBases b = new MultiTypedefBases(3, 4);
    check(b.alpha(), 0);
    check(b.beta(), 12);

    // Base named through a three-level typedef chain
    check(new DeepTypedefChain(9).value(), 9);

    // Base named through a typedef declared in a different namespace
    check(new CrossNsTypedef(11).value(), 11);
  }
}
