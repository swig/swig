%module cpp11_assign_delete

%rename(Assign) *::operator=;
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

struct MemberVars {
  // These will only have getters
  AssignPublic MemberPublic;
  AssignProtected MemberProtected;
  AssignPrivate MemberPrivate;
  AssignPublicDerived MemberPublicDerived;
  AssignProtectedDerived MemberProtectedDerived;
  AssignPrivateDerived MemberPrivateDerived;

  // These will have getters and setters
  AssignPublicDerivedSettable MemberPublicDerivedSettable;
  AssignProtectedDerivedSettable MemberProtectedDerivedSettable;
  AssignPrivateDerivedSettable MemberPrivateDerivedSettable;
};
%}
