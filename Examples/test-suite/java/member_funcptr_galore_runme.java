import member_funcptr_galore.*;

public class member_funcptr_galore_runme {

  static {
    try {
      System.loadLibrary("member_funcptr_galore");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  static void check(int got, int expected, String what) {
    if (got != expected)
      throw new RuntimeException(what + " got " + got + " expected " + expected);
  }

  public static void main(String argv[]) {
    MemberFuncPtrs m = new MemberFuncPtrs();
    check(m.aaa1(member_funcptr_galore.getCc1()), 0, "aaa1");
    check(m.aaa6(member_funcptr_galore.getCc6()), 0, "aaa6");
    check(m.aaa7(member_funcptr_galore.getCc7()), 0, "aaa7");
    check(m.bbb1(member_funcptr_galore.getPp1()), 0, "bbb1");
    check(m.bbb6(member_funcptr_galore.getPp6()), 0, "bbb6");
    check(m.bbb7(member_funcptr_galore.getPp7()), 0, "bbb7");
    check(member_funcptr_galore.call1(member_funcptr_galore.ADD_BY_VALUE, 1, 2), 3, "call1");

    // A const reference to a member pointer is passed and returned as the member pointer
    check(m.aaa7(member_funcptr_galore.getCc1()), 0, "aaa7 with cc1");
    check(m.aaa1(member_funcptr_galore.getCc7()), 0, "aaa1 with cc7");

    // A pointer to a const member function and a pointer to a non-const member function have different classes
    if (member_funcptr_galore.getCc1().getClass().equals(member_funcptr_galore.getPp1().getClass()))
      throw new RuntimeException("cc1 and pp1 have the same class");
    if (member_funcptr_galore.getCc7().getClass().equals(member_funcptr_galore.getPp7().getClass()))
      throw new RuntimeException("cc7 and pp7 have the same class");
  }
}
