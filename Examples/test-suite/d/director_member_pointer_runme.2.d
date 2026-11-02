module director_member_pointer_runme;

import director_member_pointer.MemberPtrDirector;
import director_member_pointer.SWIGTYPE_m_MemberPtrFuncs__f_int__int;
import std.conv : text;
import std.exception : enforce;

void check(int got, int expected, string what) {
  enforce(got == expected, text(what, " got ", got, " expected ", expected));
}

void main() {
  auto d = new MemberPtrDirector();
  check(d.callUseMemberPtr(5), 7, "Base useMemberPtr");
  check(d.callUseMemberPtrCref(5), 7, "Base useMemberPtrCref");
  check(d.callGetMemberPtr(5), 6, "Base getMemberPtr");
  auto md = new MyMemberPtrDirector();
  check(md.callUseMemberPtr(5), 17, "Director useMemberPtr");
  check(md.callGetMemberPtr(5), 7, "Director getMemberPtr");

  // NULL member pointers
  check(md.callUseNullMemberPtr(5), -1, "Director useMemberPtr with a null member pointer");
  md.returnNull = true;
  enforce(md.callGetMemberPtrIsNull(), "Director getMemberPtr returning null failed");
}

class MyMemberPtrDirector : MemberPtrDirector {
  bool returnNull = false;
  public override int useMemberPtr(SWIGTYPE_m_MemberPtrFuncs__f_int__int m, int x) {
    return (m is null) ? -1 : MemberPtrDirector.callMemberPtr(m, x + 10);
  }
  public override SWIGTYPE_m_MemberPtrFuncs__f_int__int getMemberPtr() {
    return returnNull ? null : MemberPtrDirector.addPtr();
  }
}
