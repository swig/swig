module member_funcptr_galore_runme;

import member_funcptr_galore.member_funcptr_galore;
import member_funcptr_galore.MemberFuncPtrs;
import std.conv : text;
import std.exception : enforce;

void check(int got, int expected, string what) {
  enforce(got == expected, text(what, " got ", got, " expected ", expected));
}

void main() {
  auto m = new MemberFuncPtrs();
  check(m.aaa1(cc1), 0, "aaa1");
  check(m.aaa6(cc6), 0, "aaa6");
  check(m.aaa7(cc7), 0, "aaa7");
  check(m.bbb1(pp1), 0, "bbb1");
  check(m.bbb6(pp6), 0, "bbb6");
  check(m.bbb7(pp7), 0, "bbb7");
  check(call1(ADD_BY_VALUE, 1, 2), 3, "call1");

  // A const reference to a member pointer is passed and returned as the member pointer
  check(m.aaa7(cc1), 0, "aaa7 with cc1");
  check(m.aaa1(cc7), 0, "aaa1 with cc7");

  // A pointer to a const member function and a pointer to a non-const member function have different classes
  auto c1 = cc1;
  auto p1 = pp1;
  enforce(typeid(c1) != typeid(p1), "cc1 and pp1 have the same class");
  auto c7 = cc7;
  auto p7 = pp7;
  enforce(typeid(c7) != typeid(p7), "cc7 and pp7 have the same class");
}
