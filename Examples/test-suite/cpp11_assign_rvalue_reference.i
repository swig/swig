%module cpp11_assign_rvalue_reference

// Copy of assign_reference.i testcase replacing reference member variables with rvalue reference member variables

%rename(Assign) *::operator=;

// (1) Test directly non-assignable member variables
%inline %{
int GlobalInt = 0;
int&& getAnIntRValueRef() { return std::move(*new int()); }
struct AssignPublic {
  AssignPublic() : PublicMember(std::move(*new int())) {}
  int &&PublicMember;
};

struct AssignProtected {
  AssignProtected() : ProtectedMember(std::move(*new int())) {}
protected:
  int &&ProtectedMember;
};

typedef const int&& ConstIntRValueRef; // also check typedef resolution
struct AssignPrivate {
  AssignPrivate() : PrivateMember(std::move(*new int())) {}
private:
  ConstIntRValueRef PrivateMember;
};

struct MemberVars {
  // These will only have getters
  AssignPublic MemberPublic;
  AssignProtected MemberProtected;
  AssignPrivate MemberPrivate;
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
