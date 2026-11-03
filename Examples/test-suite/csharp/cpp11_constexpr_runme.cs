using System;
using cpp11_constexprNamespace;

public class cpp11_constexpr_runme {
  static void check(int got, int expected, string what) {
    if (got != expected)
      throw new Exception(what + " got " + got + " expected " + expected);
  }

  static void checkDifferentClass(object a, object b) {
    if (a.GetType() == b.GetType())
      throw new Exception("both have class " + a.GetType());
  }

  static void Main() {
    // Static constexpr member pointers are passed to a function taking their type
    check(cpp11_constexpr.takeNonConstPtr(MemberPointerConstants.NonConstPtr), 1, "takeNonConstPtr");
    check(cpp11_constexpr.takeConstPtr(MemberPointerConstants.ConstPtr), 2, "takeConstPtr");
    check(cpp11_constexpr.takeVolatilePtr(MemberPointerConstants.VolatilePtr), 3, "takeVolatilePtr");
    check(cpp11_constexpr.takeConstRefPtr(MemberPointerConstants.ConstRefPtr), 4, "takeConstRefPtr");
    check(cpp11_constexpr.takeConstNoexceptPtr(MemberPointerConstants.ConstNoexceptPtr), 5, "takeConstNoexceptPtr");
    if (cpp11_constexpr.takeConstStringPtr(MemberPointerConstants.ConstStringPtr) != "six")
      throw new Exception("takeConstStringPtr failed");
    check(cpp11_constexpr.takeConstDataPtr(MemberPointerConstants.ConstDataPtr), 7, "takeConstDataPtr");
    check(cpp11_constexpr.takeTypedefPtr(MemberPointerConstants.TypedefPtr), 2, "takeTypedefPtr");
    check(cpp11_constexpr.takeConstPtr(MemberPointerConstants.TypedefPtr), 2, "takeConstPtr with TypedefPtr");

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
