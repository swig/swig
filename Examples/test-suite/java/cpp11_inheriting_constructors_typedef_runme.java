
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
    // Inheriting constructor naming Base through a typedef (Derived3's unqualified-id is Base's own name)
    check(new Derived1(7).value(), 7);
    check(new Derived2(7).value(), 7);
    check(new Derived3(7).value(), 7);
    check(new Derived4(7).value(), 7);

    // A using declaration naming a different base member imports it (a protected method), not a constructor
    check(new ImportMember("hello").protectedvalue(), 5);

    // Overloaded base constructor and a method inherited through a typedef
    check(new OverloadDerived(7).overloadvalue(), 7);
    check(new OverloadDerived(3, 4).overloadvalue(), 7);

    // Two typedef'd bases, an inheriting constructor from each
    MultiDerived a = new MultiDerived(5);
    check(a.valuea(), 5);
    check(a.valueb(), 0);
    MultiDerived b = new MultiDerived(3, 4);
    check(b.valuea(), 0);
    check(b.valueb(), 12);

    // Multi-level typedef chain
    check(new ChainDerived(9).chainvalue(), 9);

    // Typedef in a different namespace
    check(new NsDerived(11).nsvalue(), 11);

    // Over-flag guard: imports First's method Second, not a constructor
    check(new OverflowGuard().Second(5), 50);
  }
}
