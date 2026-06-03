import using_member_typedef_template.*;

public class using_member_typedef_template_runme {
  static {
    try {
        System.loadLibrary("using_member_typedef_template");
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
    // Each class member and each global function takes an Integer (a typedef chain
    // resolving to int) and returns it unchanged, so check the value survives.

    UsingDerivedA a = new UsingDerivedA();
    check(a.aa(11), 11);

    UsingDerivedB b = new UsingDerivedB();
    check(b.bb(21), 21);
    check(b.bbb(22), 22);

    UsingDerivedC c = new UsingDerivedC();
    check(c.cc(31), 31);
    check(c.ccc(32), 32);

    UsingDerivedD d = new UsingDerivedD();
    check(d.dd(41), 41);
    check(d.ddd(42), 42);

    UsingDerivedE e = new UsingDerivedE();
    check(e.ee(51), 51);
    check(e.eee(52), 52);

    UsingDerivedF f = new UsingDerivedF();
    check(f.ff(61), 61);
    check(f.fff(62), 62);

    UsingDerivedG g = new UsingDerivedG();
    check(g.gg(71), 71);
    check(g.ggg(72), 72);

    UsingDerivedH h = new UsingDerivedH();
    check(h.hh(81), 81);
    check(h.hhh(82), 82);

    UsingDerivedI i = new UsingDerivedI();
    check(i.ii(91), 91);
    check(i.iii(92), 92);

    check(using_member_typedef_template.a_tester(1), 1);
    check(using_member_typedef_template.b_tester(2), 2);
    check(using_member_typedef_template.c_tester(3), 3);
    check(using_member_typedef_template.d_tester(4), 4);
    check(using_member_typedef_template.e_tester(5), 5);
    check(using_member_typedef_template.f_tester(6), 6);
    check(using_member_typedef_template.g_tester(7), 7);
    check(using_member_typedef_template.h_tester(8), 8);
    check(using_member_typedef_template.i_tester(9), 9);
  }
}
