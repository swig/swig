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
    check(d.callUseMemberPtrCref(5), 7, "Base useMemberPtrCref");
    check(d.callGetMemberPtr(5), 6, "Base getMemberPtr");
    check(d.callGetMemberPtrCref(5), 6, "Base getMemberPtrCref");
    MyMemberPtrDirector md = new MyMemberPtrDirector();
    check(md.callUseMemberPtr(5), 17, "Director useMemberPtr");
    check(md.callUseMemberPtrCref(5), 27, "Director useMemberPtrCref");
    check(md.callGetMemberPtr(5), 7, "Director getMemberPtr");
    check(md.callGetMemberPtrCref(5), 7, "Director getMemberPtrCref");

    // NULL member pointers
    check(md.callUseNullMemberPtr(5), -1, "Director useMemberPtr with a null member pointer");
    md.returnNull = true;
    if (!md.callGetMemberPtrIsNull())
      throw new Exception("Director getMemberPtr returning null failed");
    if (!md.callGetMemberPtrCrefIsNull())
      throw new Exception("Director getMemberPtrCref returning null failed");
  }
}

public class MyMemberPtrDirector : MemberPtrDirector {
  public bool returnNull = false;
  public override int useMemberPtr(SWIGTYPE_m_MemberPtrFuncs__f_int__int m, int x) {
    return (m == null) ? -1 : MemberPtrDirector.callMemberPtr(m, x + 10);
  }
  public override int useMemberPtrCref(SWIGTYPE_m_MemberPtrFuncs__f_int__int m, int x) {
    return MemberPtrDirector.callMemberPtr(m, x + 20);
  }
  public override SWIGTYPE_m_MemberPtrFuncs__f_int__int getMemberPtr() {
    return returnNull ? null : MemberPtrDirector.addPtr();
  }
  public override SWIGTYPE_m_MemberPtrFuncs__f_int__int getMemberPtrCref() {
    return returnNull ? null : MemberPtrDirector.addPtr();
  }
}
