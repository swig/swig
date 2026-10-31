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
  check(d.callGetMemberPtr(5), 6, "Base getMemberPtr");
  d = new MyMemberPtrDirector();
  check(d.callUseMemberPtr(5), 17, "Director useMemberPtr");
  check(d.callGetMemberPtr(5), 7, "Director getMemberPtr");
}

class MyMemberPtrDirector : MemberPtrDirector {
  public override int useMemberPtr(SWIGTYPE_m_MemberPtrFuncs__f_int__int m, int x) {
    return MemberPtrDirector.callMemberPtr(m, x + 10);
  }
  public override SWIGTYPE_m_MemberPtrFuncs__f_int__int getMemberPtr() {
    return MemberPtrDirector.addPtr();
  }
}
