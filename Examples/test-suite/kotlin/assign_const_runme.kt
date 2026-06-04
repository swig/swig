@file:JvmName("assign_const_runme")

import assign_const.*

fun main() {
    try {
        System.loadLibrary("assign_const")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val mv = MemberVars()

    // (1) Test directly non-assignable member variables
    // These will only have getters
    val a1 = mv.MemberValue
    val a2 = mv.MemberArray
    val a3 = mv.MemberPtr
    val a4 = mv.MemberMatrix

    // (2) Test indirectly non-assignable member variables via inheritance
    val imv = InheritedMemberVars()
    // These will only have getters
    val aa4 = imv.MemberValueDerived
    val aa5 = imv.MemberArrayDerived
    val aa6 = imv.MemberPtrDerived
    val aa7 = imv.MemberMatrixDerived

    val sa4 = InheritedMemberVars.StaticMemberValueDerived
    val sa5 = InheritedMemberVars.StaticMemberArrayDerived
    val sa6 = InheritedMemberVars.StaticMemberPtrDerived
    val sa7 = InheritedMemberVars.StaticMemberMatrixDerived

    val ga4 = assign_const.GlobalValueDerived
    val ga5 = assign_const.GlobalArrayDerived
    val ga6 = assign_const.GlobalPtrDerived
    val ga7 = assign_const.GlobalMatrixDerived

    // These will have getters and setters
    val a7v = imv.MemberValueDerivedSettable
    imv.MemberValueDerivedSettable = a7v
    val a8 = imv.MemberArrayDerivedSettable
    imv.MemberArrayDerivedSettable = a8
    val a9 = imv.MemberPtrDerivedSettable
    imv.MemberPtrDerivedSettable = a9
    val a10 = imv.MemberMatrixDerivedSettable
    imv.MemberMatrixDerivedSettable = a10

    val saa7 = InheritedMemberVars.StaticMemberValueDerivedSettable
    InheritedMemberVars.StaticMemberValueDerivedSettable = saa7
    val saa8 = InheritedMemberVars.StaticMemberArrayDerivedSettable
    InheritedMemberVars.StaticMemberArrayDerivedSettable = saa8
    val saa9 = InheritedMemberVars.StaticMemberPtrDerivedSettable
    InheritedMemberVars.StaticMemberPtrDerivedSettable = saa9
    val saa10 = InheritedMemberVars.StaticMemberMatrixDerivedSettable
    InheritedMemberVars.StaticMemberMatrixDerivedSettable = saa10

    val gaa7 = assign_const.GlobalValueDerivedSettable
    assign_const.GlobalValueDerivedSettable = gaa7
    val gaa8 = assign_const.GlobalArrayDerivedSettable
    assign_const.GlobalArrayDerivedSettable = gaa8
    val gaa9 = assign_const.GlobalPtrDerivedSettable
    assign_const.GlobalPtrDerivedSettable = gaa9
    val gaa10 = assign_const.GlobalMatrixDerivedSettable
    assign_const.GlobalMatrixDerivedSettable = gaa10

    // (3) Test indirectly non-assignable member variables via classes that themselves have non-assignable member variables
    val m = MembersMemberVars()

    // These will only have getters
    val mpv1 = m.MemberValue
    val mpv2 = m.MemberArray
    val mpv3 = m.MemberPtr
    val mpv4 = m.MemberMatrix

    val smpv1 = StaticMembersMemberVars.StaticMemberValue
    val smpv2 = StaticMembersMemberVars.StaticMemberArray
    val smpv3 = StaticMembersMemberVars.StaticMemberPtr
    val smpv4 = StaticMembersMemberVars.StaticMemberMatrix

    val gmpv1 = assign_const.GlobalMemberValue
    val gmpv2 = assign_const.GlobalMemberArray
    val gmpv3 = assign_const.GlobalMemberPtr
    val gmpv4 = assign_const.GlobalMemberMatrix

    // Setters and getters available
    val smmvh = StaticMembersMemberVarsHolder()
    val member = smmvh.Member
    smmvh.Member = member

    val smmv = assign_const.GlobalStaticMembersMemberVars
    assign_const.GlobalStaticMembersMemberVars = smmv
}
