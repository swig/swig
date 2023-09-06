
import cpp11_assign_delete.*;

public class cpp11_assign_delete_runme {

  static {
    try {
	System.loadLibrary("cpp11_assign_delete");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
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

    // These will have getters and setters
    AssignPublicDerivedSettable a7 = imv.getMemberPublicDerivedSettable();
    imv.setMemberPublicDerivedSettable(a7);
    AssignProtectedDerivedSettable a8 = imv.getMemberProtectedDerivedSettable();
    imv.setMemberProtectedDerivedSettable(a8);
    AssignPrivateDerivedSettable a9 = imv.getMemberPrivateDerivedSettable();
    imv.setMemberPrivateDerivedSettable(a9);


    // (3) Test indirectly non-assignable member variables via classes that themselves have non-assignable member variables
    MembersMemberVars m = new MembersMemberVars();

    // These will only have getters
    MemberPublicVar mpv1 = m.getMemberPublic();
    MemberProtectedVar mpv2 = m.getMemberProtected();
    MemberPrivateVar mpv3 = m.getMemberPrivate();
  }
}
