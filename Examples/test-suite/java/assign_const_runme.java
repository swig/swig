
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

    // (2) Test indirectly non-assignable member variables via inheritance
    InheritedMemberVars imv = new InheritedMemberVars();
    // These will only have getters
    AssignValueDerived a4 = imv.getMemberValueDerived();
    AssignArrayDerived a5 = imv.getMemberArrayDerived();
    AssignPtrDerived a6 = imv.getMemberPtrDerived();

    AssignValueDerived sa4 = InheritedMemberVars.getStaticMemberValueDerived();
    AssignArrayDerived sa5 = InheritedMemberVars.getStaticMemberArrayDerived();
    AssignPtrDerived sa6 = InheritedMemberVars.getStaticMemberPtrDerived();

    AssignValueDerived ga4 = assign_const.getGlobalValueDerived();
    AssignArrayDerived ga5 = assign_const.getGlobalArrayDerived();
    AssignPtrDerived ga6 = assign_const.getGlobalPtrDerived();

    // These will have getters and setters
    AssignValueDerivedSettable a7 = imv.getMemberValueDerivedSettable();
    imv.setMemberValueDerivedSettable(a7);
    AssignArrayDerivedSettable a8 = imv.getMemberArrayDerivedSettable();
    imv.setMemberArrayDerivedSettable(a8);
    AssignPtrDerivedSettable a9 = imv.getMemberPtrDerivedSettable();
    imv.setMemberPtrDerivedSettable(a9);

    AssignValueDerivedSettable sa7 = InheritedMemberVars.getStaticMemberValueDerivedSettable();
    InheritedMemberVars.setStaticMemberValueDerivedSettable(sa7);
    AssignArrayDerivedSettable sa8 = InheritedMemberVars.getStaticMemberArrayDerivedSettable();
    InheritedMemberVars.setStaticMemberArrayDerivedSettable(sa8);
    AssignPtrDerivedSettable sa9 = InheritedMemberVars.getStaticMemberPtrDerivedSettable();
    InheritedMemberVars.setStaticMemberPtrDerivedSettable(sa9);

    AssignValueDerivedSettable ga7 = assign_const.getGlobalValueDerivedSettable();
    assign_const.setGlobalValueDerivedSettable(ga7);
    AssignArrayDerivedSettable ga8 = assign_const.getGlobalArrayDerivedSettable();
    assign_const.setGlobalArrayDerivedSettable(ga8);
    AssignPtrDerivedSettable ga9 = assign_const.getGlobalPtrDerivedSettable();
    assign_const.setGlobalPtrDerivedSettable(ga9);

    // (3) Test indirectly non-assignable member variables via classes that themselves have non-assignable member variables
    MembersMemberVars m = new MembersMemberVars();

    // These will only have getters
    MemberValueVar mpv1 = m.getMemberValue();
    MemberArrayVar mpv2 = m.getMemberArray();
    MemberPtrVar mpv3 = m.getMemberPtr();

    MemberValueVar smpv1 = StaticMembersMemberVars.getStaticMemberValue();
    MemberArrayVar smpv2 = StaticMembersMemberVars.getStaticMemberArray();
    MemberPtrVar smpv3 = StaticMembersMemberVars.getStaticMemberPtr();

    MemberValueVar gmpv1 = assign_const.getGlobalMemberValue();
    MemberArrayVar gmpv2 = assign_const.getGlobalMemberArray();
    MemberPtrVar gmpv3 = assign_const.getGlobalMemberPtr();

    // Setters and getters available
    StaticMembersMemberVarsHolder smmvh = new StaticMembersMemberVarsHolder();
    StaticMembersMemberVars member = smmvh.getMember();
    smmvh.setMember(member);

    StaticMembersMemberVars smmv = assign_const.getGlobalStaticMembersMemberVars();
    assign_const.setGlobalStaticMembersMemberVars(smmv);
  }
}
