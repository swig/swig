var member_funcptr_galore = require("member_funcptr_galore");

function check(expected, actual) {
  if (expected !== actual)
    throw new Error("Expected: " + expected + " Actual: " + actual);
}

// Only napi throws a TypeError, so check the message
function check_type_error(f) {
  try {
    f();
  } catch (e) {
    if (e.message.indexOf("argument 2 of type") === -1)
      throw e;
    return;
  }
  throw new Error("No type error thrown");
}

var m = new member_funcptr_galore.MemberFuncPtrs();
check(0, m.aaa1(member_funcptr_galore.cc1));
check(0, m.aaa6(member_funcptr_galore.cc6));
check(0, m.aaa7(member_funcptr_galore.cc7));
check(0, m.bbb1(member_funcptr_galore.pp1));
check(0, m.bbb6(member_funcptr_galore.pp6));
check(0, m.bbb7(member_funcptr_galore.pp7));
check(3, member_funcptr_galore.call1(member_funcptr_galore.ADD_BY_VALUE, 1, 2));

// A const reference to a member pointer is passed and returned as the member pointer
check(0, m.aaa7(member_funcptr_galore.cc1));
check(0, m.aaa1(member_funcptr_galore.cc7));

// A pointer to a non-const member function is not a pointer to a const member function, nor the reverse
check_type_error(function() { m.aaa1(member_funcptr_galore.pp1); });
check_type_error(function() { m.aaa7(member_funcptr_galore.pp7); });
check_type_error(function() { m.bbb1(member_funcptr_galore.cc1); });
check_type_error(function() { m.bbb7(member_funcptr_galore.cc7); });
