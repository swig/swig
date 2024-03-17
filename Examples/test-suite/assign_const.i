%module assign_const

%{
#if defined(_MSC_VER)
  #pragma warning(disable : 4351) // warning C4351: new behavior: elements of array 'AssignArray::ArrayMember' will be default initialized
#endif
%}

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

struct AssignMatrix {
  AssignMatrix() : MatrixMember() {}
  const int MatrixMember[2][2];
};

struct MemberVars {
  // These will only have getters
  AssignValue MemberValue;
  AssignArray MemberArray;
  AssignPtr MemberPtr;
  AssignMatrix MemberMatrix;
};

// (2) Test indirectly non-assignable member variables via inheritance
struct AssignValueDerived : AssignValue {};
struct AssignArrayDerived : AssignArray {};
struct AssignPtrDerived : AssignPtr {};
struct AssignMatrixDerived : AssignMatrix {};
struct AssignValueDerivedSettable : AssignValue {
  AssignValueDerivedSettable& operator=(const AssignValueDerivedSettable &) { return *this; }
};
struct AssignArrayDerivedSettable : AssignArray {
  AssignArrayDerivedSettable& operator=(const AssignArrayDerivedSettable &) { return *this; }
};
struct AssignPtrDerivedSettable : AssignPtr {
  AssignPtrDerivedSettable& operator=(const AssignPtrDerivedSettable &) { return *this; }
};
struct AssignMatrixDerivedSettable : AssignMatrix {
  AssignMatrixDerivedSettable& operator=(const AssignMatrixDerivedSettable &) { return *this; }
};

struct InheritedMemberVars {
  // These will only have getters
  AssignValueDerived MemberValueDerived;
  AssignArrayDerived MemberArrayDerived;
  AssignPtrDerived MemberPtrDerived;
  AssignMatrixDerived MemberMatrixDerived;

  static AssignValueDerived StaticMemberValueDerived;
  static AssignArrayDerived StaticMemberArrayDerived;
  static AssignPtrDerived StaticMemberPtrDerived;
  static AssignMatrixDerived StaticMemberMatrixDerived;

  // These will have getters and setters
  AssignValueDerivedSettable MemberValueDerivedSettable;
  AssignArrayDerivedSettable MemberArrayDerivedSettable;
  AssignPtrDerivedSettable MemberPtrDerivedSettable;
  AssignMatrixDerivedSettable MemberMatrixDerivedSettable;

  static AssignValueDerivedSettable StaticMemberValueDerivedSettable;
  static AssignArrayDerivedSettable StaticMemberArrayDerivedSettable;
  static AssignPtrDerivedSettable StaticMemberPtrDerivedSettable;
  static AssignMatrixDerivedSettable StaticMemberMatrixDerivedSettable;
};

AssignValueDerived InheritedMemberVars::StaticMemberValueDerived;
AssignArrayDerived InheritedMemberVars::StaticMemberArrayDerived;
AssignPtrDerived InheritedMemberVars::StaticMemberPtrDerived;
AssignMatrixDerived InheritedMemberVars::StaticMemberMatrixDerived;

AssignValueDerivedSettable InheritedMemberVars::StaticMemberValueDerivedSettable;
AssignArrayDerivedSettable InheritedMemberVars::StaticMemberArrayDerivedSettable;
AssignPtrDerivedSettable InheritedMemberVars::StaticMemberPtrDerivedSettable;
AssignMatrixDerivedSettable InheritedMemberVars::StaticMemberMatrixDerivedSettable;

// These will only have getters
AssignValueDerived GlobalValueDerived;
AssignArrayDerived GlobalArrayDerived;
AssignPtrDerived GlobalPtrDerived;
AssignMatrixDerived GlobalMatrixDerived;

// These will have getters and setters
AssignValueDerivedSettable GlobalValueDerivedSettable;
AssignArrayDerivedSettable GlobalArrayDerivedSettable;
AssignPtrDerivedSettable GlobalPtrDerivedSettable;
AssignMatrixDerivedSettable GlobalMatrixDerivedSettable;
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

struct MemberMatrixVar {
  AssignMatrix MemberMatrix;
};

struct MembersMemberVars {
  // These will only have getters
  MemberValueVar MemberValue;
  MemberArrayVar MemberArray;
  MemberPtrVar MemberPtr;
  MemberMatrixVar MemberMatrix;
};

struct StaticMembersMemberVars {
  static MemberValueVar StaticMemberValue;
  static MemberArrayVar StaticMemberArray;
  static MemberPtrVar StaticMemberPtr;
  static MemberMatrixVar StaticMemberMatrix;
};
MemberValueVar StaticMembersMemberVars::StaticMemberValue;
MemberArrayVar StaticMembersMemberVars::StaticMemberArray;
MemberPtrVar StaticMembersMemberVars::StaticMemberPtr;
MemberMatrixVar StaticMembersMemberVars::StaticMemberMatrix;

MemberValueVar GlobalMemberValue;
MemberArrayVar GlobalMemberArray;
MemberPtrVar GlobalMemberPtr;
MemberMatrixVar GlobalMemberMatrix;

// Setters and getters available
struct StaticMembersMemberVarsHolder {
    StaticMembersMemberVars Member;
};
StaticMembersMemberVars GlobalStaticMembersMemberVars;
%}
