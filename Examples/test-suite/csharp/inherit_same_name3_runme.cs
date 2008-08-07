
using inherit_same_name3Namespace;
using System;

public class inherit_same_name3_runme {
  public static void Main() {
    A c_as_A = (A) new C();

    /* C::xyz is a static function and should not override A::xyz */
    Assert(c_as_A.xyz(0) == 1);

    /* Now the static function is called directly */
    Assert(C.xyz(0) == 2);

    E f = (E) new F();

    /* E::xyz and F::xyz should be virtual */
    Assert(f.xyz(0) == 3);

    H h = new H();
    G h_as_G = (G) h;

    /* H::xyz should not override G::xyz because it has been renamed from H::xyz2 */
    Assert(h_as_G.xyz(0) == 1);
    Assert(h.xyz(0) == 2);
  }

  private static void Assert(bool val) {
    if (!val)
      throw new Exception("assertion failure in test inherit_same_name3");
  }
}

