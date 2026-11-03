import cpp11_constexpr.*;

public class cpp11_constexpr_runme {

  static {
    try {
        System.loadLibrary("cpp11_constexpr");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void check(int received, int expected) {
    if (expected != received)
      throw new RuntimeException("check failed, expected: " + expected + " received: " + received);
  }

  private static void checkDifferentClass(Object a, Object b) {
    if (a.getClass().equals(b.getClass()))
      throw new RuntimeException("check failed, both have class " + a.getClass().getName());
  }

  public static void main(String argv[])
  {
    check(cpp11_constexpr.getAAA(), 10);
    check(cpp11_constexpr.getBBB(), 20);
    check(cpp11_constexpr.CCC(), 30);
    check(cpp11_constexpr.DDD(), 40);

    ConstExpressions ce = new ConstExpressions(0);
    check(ConstExpressions.JJJ, 100);
    check(ConstExpressions.KKK, 200);
    check(ConstExpressions.LLL, 300);
    check(ce.MMM(), 400);
    check(ce.NNN(), 500);

    // Static constexpr member pointers are passed to a function taking their type
    check(cpp11_constexpr.takeNonConstPtr(MemberPointerConstants.NonConstPtr), 1);
    check(cpp11_constexpr.takeConstPtr(MemberPointerConstants.ConstPtr), 2);
    check(cpp11_constexpr.takeVolatilePtr(MemberPointerConstants.VolatilePtr), 3);
    check(cpp11_constexpr.takeConstRefPtr(MemberPointerConstants.ConstRefPtr), 4);
    check(cpp11_constexpr.takeConstNoexceptPtr(MemberPointerConstants.ConstNoexceptPtr), 5);
    if (!cpp11_constexpr.takeConstStringPtr(MemberPointerConstants.ConstStringPtr).equals("six"))
      throw new RuntimeException("takeConstStringPtr failed");
    check(cpp11_constexpr.takeConstDataPtr(MemberPointerConstants.ConstDataPtr), 7);
    check(cpp11_constexpr.takeTypedefPtr(MemberPointerConstants.TypedefPtr), 2);
    check(cpp11_constexpr.takeConstPtr(MemberPointerConstants.TypedefPtr), 2);

    // A constant of another member pointer type has a different class
    checkDifferentClass(MemberPointerConstants.ConstPtr, MemberPointerConstants.NonConstPtr);
    checkDifferentClass(MemberPointerConstants.VolatilePtr, MemberPointerConstants.ConstPtr);
    checkDifferentClass(MemberPointerConstants.ConstRefPtr, MemberPointerConstants.ConstPtr);
    checkDifferentClass(MemberPointerConstants.ConstNoexceptPtr, MemberPointerConstants.NonConstPtr);
    checkDifferentClass(MemberPointerConstants.ConstStringPtr, MemberPointerConstants.ConstPtr);
    checkDifferentClass(MemberPointerConstants.ConstDataPtr, MemberPointerConstants.ConstPtr);
    checkDifferentClass(MemberPointerConstants.TypedefPtr, MemberPointerConstants.NonConstPtr);
  }
}
