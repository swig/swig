%module cpp11_assign_delete

%rename(Assign) *::operator=;

// (1) Test directly non-assignable member variables
%inline %{
struct AssignPublic {
  AssignPublic& operator=(const AssignPublic &) = delete;
};

struct AssignProtected {
protected:
  AssignProtected& operator=(const AssignProtected &) = delete;
};

struct AssignPrivate {
private:
  AssignPrivate& operator=(const AssignPrivate &) = delete;
};

struct MemberVars {
  // These will only have getters
  AssignPublic MemberPublic;
  AssignProtected MemberProtected;
  AssignPrivate MemberPrivate;
};

struct MemberArrayVars {
  // These will only have getters
  AssignPublic ArrayMemberPublic[1];
  AssignProtected ArrayMemberProtected[1];
  AssignPrivate ArrayMemberPrivate[1];
};

// (2) Test indirectly non-assignable member variables via inheritance
struct AssignPublicDerived : AssignPublic {};
struct AssignProtectedDerived : AssignProtected {};
struct AssignPrivateDerived : AssignPrivate {};
struct AssignPublicDerivedSettable : AssignPublic {
  AssignPublicDerivedSettable& operator=(const AssignPublicDerivedSettable &) { return *this; }
};
struct AssignProtectedDerivedSettable : AssignProtected {
  AssignProtectedDerivedSettable& operator=(const AssignProtectedDerivedSettable &) { return *this; }
};
struct AssignPrivateDerivedSettable : AssignPrivate {
  AssignPrivateDerivedSettable& operator=(const AssignPrivateDerivedSettable &) { return *this; }
};

struct InheritedMemberVars {
  // These will only have getters
  AssignPublicDerived MemberPublicDerived;
  AssignProtectedDerived MemberProtectedDerived;
  AssignPrivateDerived MemberPrivateDerived;

  static AssignPublicDerived StaticMemberPublicDerived;
  static AssignProtectedDerived StaticMemberProtectedDerived;
  static AssignPrivateDerived StaticMemberPrivateDerived;

  // These will have getters and setters
  AssignPublicDerivedSettable MemberPublicDerivedSettable;
  AssignProtectedDerivedSettable MemberProtectedDerivedSettable;
  AssignPrivateDerivedSettable MemberPrivateDerivedSettable;

  static AssignPublicDerivedSettable StaticMemberPublicDerivedSettable;
  static AssignProtectedDerivedSettable StaticMemberProtectedDerivedSettable;
  static AssignPrivateDerivedSettable StaticMemberPrivateDerivedSettable;
};

AssignPublicDerived InheritedMemberVars::StaticMemberPublicDerived;
AssignProtectedDerived InheritedMemberVars::StaticMemberProtectedDerived;
AssignPrivateDerived InheritedMemberVars::StaticMemberPrivateDerived;

AssignPublicDerivedSettable InheritedMemberVars::StaticMemberPublicDerivedSettable;
AssignProtectedDerivedSettable InheritedMemberVars::StaticMemberProtectedDerivedSettable;
AssignPrivateDerivedSettable InheritedMemberVars::StaticMemberPrivateDerivedSettable;

// These will only have getters
AssignPublicDerived GlobalPublicDerived;
AssignProtectedDerived GlobalProtectedDerived;
AssignPrivateDerived GlobalPrivateDerived;

// These will have getters and setters
AssignPublicDerivedSettable GlobalPublicDerivedSettable;
AssignProtectedDerivedSettable GlobalProtectedDerivedSettable;
AssignPrivateDerivedSettable GlobalPrivateDerivedSettable;
%}

// (3) Test indirectly non-assignable member variables via classes that themselves have non-assignable member variables
%inline %{
struct MemberPublicVar {
  AssignPublic MemberPublic;
};

struct MemberProtectedVar {
protected:
  AssignProtected MemberProtected;
};

struct MemberPrivateVar {
private:
  AssignPrivate MemberPrivate;
};

struct MembersMemberVars {
  // These will only have getters
  MemberPublicVar MemberPublic;
  MemberProtectedVar MemberProtected;
  MemberPrivateVar MemberPrivate;
};

struct StaticMembersMemberVars {
  static MemberPublicVar StaticMemberPublic;
  static MemberProtectedVar StaticMemberProtected;
  static MemberPrivateVar StaticMemberPrivate;
};
MemberPublicVar StaticMembersMemberVars::StaticMemberPublic;
MemberProtectedVar StaticMembersMemberVars::StaticMemberProtected;
MemberPrivateVar StaticMembersMemberVars::StaticMemberPrivate;

MemberPublicVar GlobalMemberPublic;
MemberProtectedVar GlobalMemberProtected;
MemberPrivateVar GlobalMemberPrivate;

// Setters and getters available
struct StaticMembersMemberVarsHolder {
    StaticMembersMemberVars Member;
};
StaticMembersMemberVars GlobalStaticMembersMemberVars;
%}

// (4) Test indirectly non-assignable member variables via classes that themselves have non-assignable array member variables
%inline %{
struct MemberPublicArrayVar {
  AssignPublic MemberPublic[1];
};

struct MemberProtectedArrayVar {
protected:
  AssignProtected MemberProtected[1];
};

struct MemberPrivateArrayVar {
private:
  AssignPrivate MemberPrivate[1];
};

struct MembersMemberArrayVars {
  // These will only have getters
  MemberPublicArrayVar MemberPublic;
  MemberProtectedArrayVar MemberProtected;
  MemberPrivateArrayVar MemberPrivate;
};

struct StaticMembersMemberArrayVars {
  static MemberPublicArrayVar StaticMemberPublic;
  static MemberProtectedArrayVar StaticMemberProtected;
  static MemberPrivateArrayVar StaticMemberPrivate;
};
MemberPublicArrayVar StaticMembersMemberArrayVars::StaticMemberPublic;
MemberProtectedArrayVar StaticMembersMemberArrayVars::StaticMemberProtected;
MemberPrivateArrayVar StaticMembersMemberArrayVars::StaticMemberPrivate;

MemberPublicArrayVar GlobalArrayMemberPublic;
MemberProtectedArrayVar GlobalArrayMemberProtected;
MemberPrivateArrayVar GlobalArrayMemberPrivate;

// Setters and getters available
struct StaticMembersMemberArrayVarsHolder {
    StaticMembersMemberArrayVars Member;
};
StaticMembersMemberArrayVars GlobalStaticMembersMemberArrayVars;
%}

// (5) Test indirectly non-assignable member variables via classes that themselves have non-assignable reference member variables
%inline %{
AssignPublic GlobalAssignPublic;
AssignProtected GlobalAssignProtected;
AssignPrivate GlobalAssignPrivate;

struct MemberPublicRefVar {
  AssignPublic& MemberRefVarPublic;
  MemberPublicRefVar() : MemberRefVarPublic(GlobalAssignPublic) {}
};

struct MemberProtectedRefVar {
  MemberProtectedRefVar() : MemberRefVarProtected(GlobalAssignProtected) {}
protected:
  AssignProtected& MemberRefVarProtected;
};

struct MemberPrivateRefVar {
  MemberPrivateRefVar() : MemberRefVarPrivate(GlobalAssignPrivate) {}
private:
  AssignPrivate& MemberRefVarPrivate;
};

struct MembersMemberRefVars {
  // These will only have getters
  MemberPublicRefVar MemberPublic;
  MemberProtectedRefVar MemberProtected;
  MemberPrivateRefVar MemberPrivate;
};

struct StaticMembersMemberRefVars {
  static MemberPublicRefVar StaticMemberPublic;
  static MemberProtectedRefVar StaticMemberProtected;
  static MemberPrivateRefVar StaticMemberPrivate;
};
MemberPublicRefVar StaticMembersMemberRefVars::StaticMemberPublic;
MemberProtectedRefVar StaticMembersMemberRefVars::StaticMemberProtected;
MemberPrivateRefVar StaticMembersMemberRefVars::StaticMemberPrivate;

MemberPublicRefVar GlobalRefMemberPublic;
MemberProtectedRefVar GlobalRefMemberProtected;
MemberPrivateRefVar GlobalRefMemberPrivate;

// Setters and getters available
struct StaticMembersMemberRefVarsHolder {
    StaticMembersMemberRefVars Member;
};
StaticMembersMemberRefVars GlobalStaticMembersMemberRefVars;
%}
