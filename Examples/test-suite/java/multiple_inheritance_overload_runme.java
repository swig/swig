import multiple_inheritance_overload.*;

public class multiple_inheritance_overload_runme {

  static {
    try {
      System.loadLibrary("multiple_inheritance_overload");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void check(boolean fail, String msg) {
    if (fail)
      throw new RuntimeException(msg);
  }

  public static void main(String argv[]) {
    int i = 0;
    Base b1 = new Derived();
    check(b1.Method(i) != 0, "b1.Method failed");
    check(b1.MethodForRenaming(i) != 0, "b1.MethodForRenaming failed");
    check(b1.MethodForRenamingConst(i) != 1, "b1.MethodForRenamingConst failed");
    check(b1.MethodWarningSuppressed(i) != 0, "b1.MethodWarningSuppressed failed");
    check(b1.NotVirtualMethod(i) != 0, "b1.NotVirtualMethod failed");
    check(b1.SimilarOverloadedMethod(i) != 0, "b1.NotVirtualMethod failed");

    Derived d1 = new Derived();
    check(d1.Method(i) != 0, "d1.Method failed");
    check(d1.MethodForRenaming(i) != 0, "d1.MethodForRenaming failed");
    check(d1.MethodForRenamingConst(i) != 1, "d1.MethodForRenamingConst failed");
    check(d1.MethodWarningSuppressed(i) != 0, "d1.MethodWarningSuppressed failed");
    check(d1.NotVirtualMethod(i) != 0, "d1.NotVirtualMethod failed");
    check(d1.SimilarOverloadedMethod(i) != 0, "d1.NotVirtualMethod failed");

    check(d1.AnotherMethod(i) != 0, "d1.AnotherMethod failed");

    Base db1 = BaseSwigImpl.in_out(d1);
    check(db1.Method(i) != 0, "db1.Method failed");
    check(db1.MethodForRenaming(i) != 0, "db1.MethodForRenaming failed");
    check(db1.MethodForRenamingConst(i) != 1, "db1.MethodForRenamingConst failed");
    check(db1.MethodWarningSuppressed(i) != 0, "db1.MethodWarningSuppressed failed");
    check(db1.NotVirtualMethod(i) != 0, "db1.NotVirtualMethod failed");
    check(db1.SimilarOverloadedMethod(i) != 0, "db1.NotVirtualMethod failed");

    MoreDerived m1 = new MoreDerived();
    check(m1.Method(i) != 0, "m1.Method failed");
    check(m1.MethodForRenaming(i) != 0, "m1.MethodForRenaming failed");
    check(m1.MethodForRenamingConst(i) != 1, "m1.MethodForRenamingConst failed");
    check(m1.MethodWarningSuppressed(i) != 0, "m1.MethodWarningSuppressed failed");
    check(m1.NotVirtualMethod(i) != 0, "m1.NotVirtualMethod failed");
    check(m1.SimilarOverloadedMethod(i) != 0, "m1.NotVirtualMethod failed");

    check(m1.AnotherMethod(i) != 0, "m1.AnotherMethod failed");

    Base mb2 = BaseSwigImpl.in_out(m1);
    check(mb2.Method(i) != 0, "mb2.Method failed");
    check(mb2.MethodForRenaming(i) != 0, "mb2.MethodForRenaming failed");
    check(mb2.MethodForRenamingConst(i) != 1, "mb2.MethodForRenamingConst failed");
    check(mb2.MethodWarningSuppressed(i) != 0, "mb2.MethodWarningSuppressed failed");
    check(mb2.NotVirtualMethod(i) != 0, "mb2.NotVirtualMethod failed");
    check(mb2.SimilarOverloadedMethod(i) != 0, "mb2.NotVirtualMethod failed");
  }
}
