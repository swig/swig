using System;
using director_member_pointerNamespace;

public class director_member_pointer_runme
{
  static void check(int got, int expected, string what) {
    if (got != expected)
      throw new Exception(what + " got " + got + " expected " + expected);
  }

  static void Main()
  {
    MemberPtrDirector d = new MemberPtrDirector();
    check(d.callUseMemberPtr(5), 7, "Base useMemberPtr");
    check(d.callGetMemberPtr(5), 6, "Base getMemberPtr");
    d = new MyMemberPtrDirector();
    check(d.callUseMemberPtr(5), 17, "Director useMemberPtr");
    check(d.callGetMemberPtr(5), 7, "Director getMemberPtr");
  }
}

public class MyMemberPtrDirector : MemberPtrDirector {
  public override int useMemberPtr(SWIGTYPE_m_MemberPtrFuncs__f_int__int m, int x) {
    return MemberPtrDirector.callMemberPtr(m, x + 10);
  }
  public override SWIGTYPE_m_MemberPtrFuncs__f_int__int getMemberPtr() {
    return MemberPtrDirector.addPtr();
  }
}
