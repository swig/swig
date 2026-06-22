import cpp17_using_pack_alias_template.*;

public class cpp17_using_pack_alias_template_runme {
  static {
    try {
        System.loadLibrary("cpp17_using_pack_alias_template");
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
    // Both overloads of g, inherited through the alias template base pack 'Identity<Ts>...' and
    // re-exported by the using-declaration pack 'using Identity<Ts>::g...;', are wrapped.
    OverAB o = new OverAB();
    check(o.g(), 1);     // inherited from A through Identity<A>
    check(o.g(7), 7);    // inherited from B through Identity<B>

    // Both inherited constructors, brought in through the alias template base pack
    // 'using Identity<Ts>::Identity...;', are wrapped on the derived proxy.
    new CtorWrapIS(5);   // inherited CtorA(int)
    check(cpp17_using_pack_alias_template.last_ctor(), 105);
    new CtorWrapIS(2, 3); // inherited CtorB(int, int)
    check(cpp17_using_pack_alias_template.last_ctor(), 205);
  }
}
