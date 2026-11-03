using System;
using member_funcptr_galoreNamespace;

public class member_funcptr_galore_runme {
  static void check(int got, int expected, string what) {
    if (got != expected)
      throw new Exception(what + " got " + got + " expected " + expected);
  }

  static void Main() {
    MemberFuncPtrs m = new MemberFuncPtrs();
    check(m.aaa1(member_funcptr_galore.cc1), 0, "aaa1");
    check(m.aaa6(member_funcptr_galore.cc6), 0, "aaa6");
    check(m.aaa7(member_funcptr_galore.cc7), 0, "aaa7");
    check(m.bbb1(member_funcptr_galore.pp1), 0, "bbb1");
    check(m.bbb6(member_funcptr_galore.pp6), 0, "bbb6");
    check(m.bbb7(member_funcptr_galore.pp7), 0, "bbb7");
    check(member_funcptr_galore.call1(member_funcptr_galore.ADD_BY_VALUE, 1, 2), 3, "call1");

    // A const reference to a member pointer is passed and returned as the member pointer
    check(m.aaa7(member_funcptr_galore.cc1), 0, "aaa7 with cc1");
    check(m.aaa1(member_funcptr_galore.cc7), 0, "aaa1 with cc7");

    // A pointer to a const member function and a pointer to a non-const member function have different classes
    if (member_funcptr_galore.cc1.GetType() == member_funcptr_galore.pp1.GetType())
      throw new Exception("cc1 and pp1 have the same class");
    if (member_funcptr_galore.cc7.GetType() == member_funcptr_galore.pp7.GetType())
      throw new Exception("cc7 and pp7 have the same class");
  }
}
