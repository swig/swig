
import assign_reference.*;

public class assign_reference_runme {

  static {
    try {
	System.loadLibrary("assign_reference");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    AssignPublic ap = new AssignPublic();
    SWIGTYPE_p_int pint = ap.getPublicMember();
    ap.setPublicMember(assign_reference.getGlobalIntRef());

    MemberVars mv = new MemberVars();

    // (1) Test directly non-assignable member variables
    // These will only have getters
    AssignPublic a1 = mv.getMemberPublic();
    AssignProtected a2 = mv.getMemberProtected();
    AssignPrivate a3 = mv.getMemberPrivate();

    // (2) Test indirectly non-assignable member variables via inheritance
    InheritedMemberVars imv = new InheritedMemberVars();
    // These will only have getters
    AssignPublicDerived a4 = imv.getMemberPublicDerived();
    AssignProtectedDerived a5 = imv.getMemberProtectedDerived();
    AssignPrivateDerived a6 = imv.getMemberPrivateDerived();

    AssignPublicDerived sa4 = InheritedMemberVars.getStaticMemberPublicDerived();
    AssignProtectedDerived sa5 = InheritedMemberVars.getStaticMemberProtectedDerived();
    AssignPrivateDerived sa6 = InheritedMemberVars.getStaticMemberPrivateDerived();

    AssignPublicDerived ga4 = assign_reference.getGlobalPublicDerived();
    AssignProtectedDerived ga5 = assign_reference.getGlobalProtectedDerived();
    AssignPrivateDerived ga6 = assign_reference.getGlobalPrivateDerived();

    // These will have getters and setters
    AssignPublicDerivedSettable a7 = imv.getMemberPublicDerivedSettable();
    imv.setMemberPublicDerivedSettable(a7);
    AssignProtectedDerivedSettable a8 = imv.getMemberProtectedDerivedSettable();
    imv.setMemberProtectedDerivedSettable(a8);
    AssignPrivateDerivedSettable a9 = imv.getMemberPrivateDerivedSettable();
    imv.setMemberPrivateDerivedSettable(a9);

    AssignPublicDerivedSettable sa7 = InheritedMemberVars.getStaticMemberPublicDerivedSettable();
    InheritedMemberVars.setStaticMemberPublicDerivedSettable(sa7);
    AssignProtectedDerivedSettable sa8 = InheritedMemberVars.getStaticMemberProtectedDerivedSettable();
    InheritedMemberVars.setStaticMemberProtectedDerivedSettable(sa8);
    AssignPrivateDerivedSettable sa9 = InheritedMemberVars.getStaticMemberPrivateDerivedSettable();
    InheritedMemberVars.setStaticMemberPrivateDerivedSettable(sa9);

    AssignPublicDerivedSettable ga7 = assign_reference.getGlobalPublicDerivedSettable();
    assign_reference.setGlobalPublicDerivedSettable(ga7);
    AssignProtectedDerivedSettable ga8 = assign_reference.getGlobalProtectedDerivedSettable();
    assign_reference.setGlobalProtectedDerivedSettable(ga8);
    AssignPrivateDerivedSettable ga9 = assign_reference.getGlobalPrivateDerivedSettable();
    assign_reference.setGlobalPrivateDerivedSettable(ga9);

    // (3) Test indirectly non-assignable member variables via classes that themselves have non-assignable member variables
    MembersMemberVars m = new MembersMemberVars();

    // These will only have getters
    MemberPublicVar mpv1 = m.getMemberPublic();
    MemberProtectedVar mpv2 = m.getMemberProtected();
    MemberPrivateVar mpv3 = m.getMemberPrivate();

    MemberPublicVar smpv1 = StaticMembersMemberVars.getStaticMemberPublic();
    MemberProtectedVar smpv2 = StaticMembersMemberVars.getStaticMemberProtected();
    MemberPrivateVar smpv3 = StaticMembersMemberVars.getStaticMemberPrivate();

    MemberPublicVar gmpv1 = assign_reference.getGlobalMemberPublic();
    MemberProtectedVar gmpv2 = assign_reference.getGlobalMemberProtected();
    MemberPrivateVar gmpv3 = assign_reference.getGlobalMemberPrivate();

    // Setters and getters available
    StaticMembersMemberVarsHolder smmvh = new StaticMembersMemberVarsHolder();
    StaticMembersMemberVars member = smmvh.getMember();
    smmvh.setMember(member);

    StaticMembersMemberVars smmv = assign_reference.getGlobalStaticMembersMemberVars();
    assign_reference.setGlobalStaticMembersMemberVars(smmv);
  }
}
