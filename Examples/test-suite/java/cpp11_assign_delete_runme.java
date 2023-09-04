
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

    // These will only have getters
    AssignPublic a1 = mv.getMemberPublic();
    AssignProtected a2 = mv.getMemberProtected();
    AssignPrivate a3 = mv.getMemberPrivate();
    AssignPublicDerived a4 = mv.getMemberPublicDerived();
    AssignProtectedDerived a5 = mv.getMemberProtectedDerived();
    AssignPrivateDerived a6 = mv.getMemberPrivateDerived();

    // These will have getters and setters
    AssignPublicDerivedSettable a7 = mv.getMemberPublicDerivedSettable();
    mv.setMemberPublicDerivedSettable(a7);
    AssignProtectedDerivedSettable a8 = mv.getMemberProtectedDerivedSettable();
    mv.setMemberProtectedDerivedSettable(a8);
    AssignPrivateDerivedSettable a9 = mv.getMemberPrivateDerivedSettable();
    mv.setMemberPrivateDerivedSettable(a9);
  }
}
