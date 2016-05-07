
using inherit_same_name2Namespace;
using System;

public class inherit_same_name2_runme {
  public static void Main() {
    D e = (D) new E();

    /* Function aaa is virtual in C (a superclass of D), therefore it should be virtual in D and E */
    Assert(e.aaa() == 2);

    G g = new G();
    F g_as_f = (F) g;

    /* Virtual function G::aaa is renamed to aaa2, but should still be accessible */
    Assert(g.aaa2() == 2);
    Assert(g.aaa() == 2);
    Assert(g_as_f.aaa() == 2);
  }

  private static void Assert(bool val) {
    if (!val)
      throw new Exception("assertion failure in test inherit_same_name2");
  }
}

