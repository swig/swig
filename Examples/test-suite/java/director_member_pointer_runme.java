import director_member_pointer.*;

public class director_member_pointer_runme {

  static {
    try {
      System.loadLibrary("director_member_pointer");
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
      throw new RuntimeException("Director getMemberPtr returning null failed");
    if (!md.callGetMemberPtrCrefIsNull())
      throw new RuntimeException("Director getMemberPtrCref returning null failed");
  }
}

class MyMemberPtrDirector extends MemberPtrDirector {
  boolean returnNull = false;
  @Override
  public int useMemberPtr(SWIGTYPE_m_MemberPtrFuncs__f_int__int m, int x) {
    return (m == null) ? -1 : MemberPtrDirector.callMemberPtr(m, x + 10);
  }
  @Override
  public int useMemberPtrCref(SWIGTYPE_m_MemberPtrFuncs__f_int__int m, int x) {
    return MemberPtrDirector.callMemberPtr(m, x + 20);
  }
  @Override
  public SWIGTYPE_m_MemberPtrFuncs__f_int__int getMemberPtr() {
    return returnNull ? null : MemberPtrDirector.addPtr();
  }
  @Override
  public SWIGTYPE_m_MemberPtrFuncs__f_int__int getMemberPtrCref() {
    return returnNull ? null : MemberPtrDirector.addPtr();
  }
}
