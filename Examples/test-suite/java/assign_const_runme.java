
import assign_const.*;

public class assign_const_runme {

  static {
    try {
	System.loadLibrary("assign_const");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    MemberVars mv = new MemberVars();

    // (1) Test directly non-assignable member variables
    // These will only have getters
    AssignValue a1 = mv.getMemberValue();
    AssignArray a2 = mv.getMemberArray();
    AssignPtr a3 = mv.getMemberPtr();
    AssignMatrix a4 = mv.getMemberMatrix();

    // (2) Test indirectly non-assignable member variables via inheritance
    InheritedMemberVars imv = new InheritedMemberVars();
    // These will only have getters
    AssignValueDerived aa4 = imv.getMemberValueDerived();
    AssignArrayDerived aa5 = imv.getMemberArrayDerived();
    AssignPtrDerived aa6 = imv.getMemberPtrDerived();
    AssignMatrixDerived aa7 = imv.getMemberMatrixDerived();

    AssignValueDerived sa4 = InheritedMemberVars.getStaticMemberValueDerived();
    AssignArrayDerived sa5 = InheritedMemberVars.getStaticMemberArrayDerived();
    AssignPtrDerived sa6 = InheritedMemberVars.getStaticMemberPtrDerived();
    AssignMatrixDerived sa7 = InheritedMemberVars.getStaticMemberMatrixDerived();

    AssignValueDerived ga4 = assign_const.getGlobalValueDerived();
    AssignArrayDerived ga5 = assign_const.getGlobalArrayDerived();
    AssignPtrDerived ga6 = assign_const.getGlobalPtrDerived();
    AssignMatrixDerived ga7 = assign_const.getGlobalMatrixDerived();

    // These will have getters and setters
    AssignValueDerivedSettable a7 = imv.getMemberValueDerivedSettable();
    imv.setMemberValueDerivedSettable(a7);
    AssignArrayDerivedSettable a8 = imv.getMemberArrayDerivedSettable();
    imv.setMemberArrayDerivedSettable(a8);
    AssignPtrDerivedSettable a9 = imv.getMemberPtrDerivedSettable();
    imv.setMemberPtrDerivedSettable(a9);
    AssignMatrixDerivedSettable a10 = imv.getMemberMatrixDerivedSettable();
    imv.setMemberMatrixDerivedSettable(a10);

    AssignValueDerivedSettable saa7 = InheritedMemberVars.getStaticMemberValueDerivedSettable();
    InheritedMemberVars.setStaticMemberValueDerivedSettable(saa7);
    AssignArrayDerivedSettable saa8 = InheritedMemberVars.getStaticMemberArrayDerivedSettable();
    InheritedMemberVars.setStaticMemberArrayDerivedSettable(saa8);
    AssignPtrDerivedSettable saa9 = InheritedMemberVars.getStaticMemberPtrDerivedSettable();
    InheritedMemberVars.setStaticMemberPtrDerivedSettable(saa9);
    AssignMatrixDerivedSettable saa10 = InheritedMemberVars.getStaticMemberMatrixDerivedSettable();
    InheritedMemberVars.setStaticMemberMatrixDerivedSettable(saa10);

    AssignValueDerivedSettable gaa7 = assign_const.getGlobalValueDerivedSettable();
    assign_const.setGlobalValueDerivedSettable(gaa7);
    AssignArrayDerivedSettable gaa8 = assign_const.getGlobalArrayDerivedSettable();
    assign_const.setGlobalArrayDerivedSettable(gaa8);
    AssignPtrDerivedSettable gaa9 = assign_const.getGlobalPtrDerivedSettable();
    assign_const.setGlobalPtrDerivedSettable(gaa9);
    AssignMatrixDerivedSettable gaa10 = assign_const.getGlobalMatrixDerivedSettable();
    assign_const.setGlobalMatrixDerivedSettable(gaa10);

    // (3) Test indirectly non-assignable member variables via classes that themselves have non-assignable member variables
    MembersMemberVars m = new MembersMemberVars();

    // These will only have getters
    MemberValueVar mpv1 = m.getMemberValue();
    MemberArrayVar mpv2 = m.getMemberArray();
    MemberPtrVar mpv3 = m.getMemberPtr();
    MemberMatrixVar mpv4 = m.getMemberMatrix();

    MemberValueVar smpv1 = StaticMembersMemberVars.getStaticMemberValue();
    MemberArrayVar smpv2 = StaticMembersMemberVars.getStaticMemberArray();
    MemberPtrVar smpv3 = StaticMembersMemberVars.getStaticMemberPtr();
    MemberMatrixVar smpv4 = StaticMembersMemberVars.getStaticMemberMatrix();

    MemberValueVar gmpv1 = assign_const.getGlobalMemberValue();
    MemberArrayVar gmpv2 = assign_const.getGlobalMemberArray();
    MemberPtrVar gmpv3 = assign_const.getGlobalMemberPtr();
    MemberMatrixVar gmpv4 = assign_const.getGlobalMemberMatrix();

    // Setters and getters available
    StaticMembersMemberVarsHolder smmvh = new StaticMembersMemberVarsHolder();
    StaticMembersMemberVars member = smmvh.getMember();
    smmvh.setMember(member);

    StaticMembersMemberVars smmv = assign_const.getGlobalStaticMembersMemberVars();
    assign_const.setGlobalStaticMembersMemberVars(smmv);
  }
}
