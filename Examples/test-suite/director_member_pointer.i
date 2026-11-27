%module(directors="1") director_member_pointer

%warnfilter(SWIGWARN_TYPEMAP_DIRECTOROUT_PTR) MemberPtrDirector::getMemberPtr;
%warnfilter(SWIGWARN_TYPEMAP_THREAD_UNSAFE,SWIGWARN_TYPEMAP_DIRECTOROUT_PTR) MemberPtrDirector::getMemberPtrCref;

%{
struct MemberPtrPad {
  MemberPtrPad() : pad(100) {}
  int pad;
};

struct MemberPtrAdder {
  MemberPtrAdder() : amount(2) {}
  int add(int x) { return x + amount; }
  int amount;
};

/* A member pointer to MemberPtrAdder::add needs a this adjustment as MemberPtrAdder is not the first base */
struct MemberPtrFuncs : MemberPtrPad, MemberPtrAdder {
  int increment(int x) { return x + 1; }
};
%}

%feature("director") MemberPtrDirector;

%inline %{
class MemberPtrDirector {
public:
  virtual ~MemberPtrDirector() {}
  virtual int useMemberPtr(int (MemberPtrFuncs::*m)(int), int x) { return callMemberPtr(m, x); }
  virtual int useMemberPtrCref(int (MemberPtrFuncs::*const &m)(int), int x) { return callMemberPtr(m, x); }
  virtual int (MemberPtrFuncs::*getMemberPtr())(int) { return &MemberPtrFuncs::increment; }
  virtual int (MemberPtrFuncs::*const &getMemberPtrCref())(int) { static int (MemberPtrFuncs::*m)(int) = &MemberPtrFuncs::increment; return m; }
  int callUseMemberPtr(int x) { return useMemberPtr(&MemberPtrAdder::add, x); }
  int callUseMemberPtrCref(int x) { return useMemberPtrCref(&MemberPtrAdder::add, x); }
  int callGetMemberPtr(int x) { return callMemberPtr(getMemberPtr(), x); }
  int callGetMemberPtrCref(int x) { return callMemberPtr(getMemberPtrCref(), x); }
  int callUseNullMemberPtr(int x) { return useMemberPtr(0, x); }
  bool callGetMemberPtrIsNull() { return getMemberPtr() == 0; }
  bool callGetMemberPtrCrefIsNull() { return getMemberPtrCref() == 0; }
  static int callMemberPtr(int (MemberPtrFuncs::*m)(int), int x) { MemberPtrFuncs f; return (f.*m)(x); }
  static int (MemberPtrFuncs::*addPtr())(int) { return &MemberPtrAdder::add; }
};
%}
