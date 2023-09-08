%module assign_const

// Similar to assign_reference.i testcase but reference member variables replaced by const members

%rename(Assign) *::operator=;

// (1) Test directly non-assignable member variables
%inline %{
struct AssignValue {
  AssignValue() : ValueMember() {}
  const int ValueMember;
};

struct AssignArray {
  AssignArray() : ArrayMember() {}
  const int ArrayMember[1];
};

struct AssignPtr {
  AssignPtr() : PtrMember() {}
  int *const PtrMember;
};

struct MemberVars {
  // These will only have getters
  AssignValue MemberValue;
  AssignArray MemberArray;
  AssignPtr MemberPtr;
};

// (2) Test indirectly non-assignable member variables via inheritance
struct AssignValueDerived : AssignValue {};
struct AssignArrayDerived : AssignArray {};
struct AssignPtrDerived : AssignPtr {};
struct AssignValueDerivedSettable : AssignValue {
  AssignValueDerivedSettable& operator=(const AssignValueDerivedSettable &) { return *this; }
};
struct AssignArrayDerivedSettable : AssignArray {
  AssignArrayDerivedSettable& operator=(const AssignArrayDerivedSettable &) { return *this; }
};
struct AssignPtrDerivedSettable : AssignPtr {
  AssignPtrDerivedSettable& operator=(const AssignPtrDerivedSettable &) { return *this; }
};

struct InheritedMemberVars {
  // These will only have getters
  AssignValueDerived MemberValueDerived;
  AssignArrayDerived MemberArrayDerived;
  AssignPtrDerived MemberPtrDerived;

  static AssignValueDerived StaticMemberValueDerived;
  static AssignArrayDerived StaticMemberArrayDerived;
  static AssignPtrDerived StaticMemberPtrDerived;

  // These will have getters and setters
  AssignValueDerivedSettable MemberValueDerivedSettable;
  AssignArrayDerivedSettable MemberArrayDerivedSettable;
  AssignPtrDerivedSettable MemberPtrDerivedSettable;

  static AssignValueDerivedSettable StaticMemberValueDerivedSettable;
  static AssignArrayDerivedSettable StaticMemberArrayDerivedSettable;
  static AssignPtrDerivedSettable StaticMemberPtrDerivedSettable;
};

AssignValueDerived InheritedMemberVars::StaticMemberValueDerived;
AssignArrayDerived InheritedMemberVars::StaticMemberArrayDerived;
AssignPtrDerived InheritedMemberVars::StaticMemberPtrDerived;

AssignValueDerivedSettable InheritedMemberVars::StaticMemberValueDerivedSettable;
AssignArrayDerivedSettable InheritedMemberVars::StaticMemberArrayDerivedSettable;
AssignPtrDerivedSettable InheritedMemberVars::StaticMemberPtrDerivedSettable;

// These will only have getters
AssignValueDerived GlobalValueDerived;
AssignArrayDerived GlobalArrayDerived;
AssignPtrDerived GlobalPtrDerived;

// These will have getters and setters
AssignValueDerivedSettable GlobalValueDerivedSettable;
AssignArrayDerivedSettable GlobalArrayDerivedSettable;
AssignPtrDerivedSettable GlobalPtrDerivedSettable;
%}

// (3) Test indirectly non-assignable member variables via classes that themselves have non-assignable member variables
%inline %{
struct MemberValueVar {
  AssignValue MemberValue;
};

struct MemberArrayVar {
  AssignArray MemberArray;
};

struct MemberPtrVar {
  AssignPtr MemberPtr;
};

struct MembersMemberVars {
  // These will only have getters
  MemberValueVar MemberValue;
  MemberArrayVar MemberArray;
  MemberPtrVar MemberPtr;
};

struct StaticMembersMemberVars {
  static MemberValueVar StaticMemberValue;
  static MemberArrayVar StaticMemberArray;
  static MemberPtrVar StaticMemberPtr;
};
MemberValueVar StaticMembersMemberVars::StaticMemberValue;
MemberArrayVar StaticMembersMemberVars::StaticMemberArray;
MemberPtrVar StaticMembersMemberVars::StaticMemberPtr;

MemberValueVar GlobalMemberValue;
MemberArrayVar GlobalMemberArray;
MemberPtrVar GlobalMemberPtr;

// Setters and getters available
struct StaticMembersMemberVarsHolder {
    StaticMembersMemberVars Member;
};
StaticMembersMemberVars GlobalStaticMembersMemberVars;
%}
