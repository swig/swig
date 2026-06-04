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
    @Suppress("UNUSED_VARIABLE")
    val a1 = mv.MemberValue
    @Suppress("UNUSED_VARIABLE")
    val a2 = mv.MemberArray
    @Suppress("UNUSED_VARIABLE")
    val a3 = mv.MemberPtr
    @Suppress("UNUSED_VARIABLE")
    val a4 = mv.MemberMatrix

    // (2) Test indirectly non-assignable member variables via inheritance
    val imv = InheritedMemberVars()
    // These will only have getters
    @Suppress("UNUSED_VARIABLE")
    val aa4 = imv.MemberValueDerived
    @Suppress("UNUSED_VARIABLE")
    val aa5 = imv.MemberArrayDerived
    @Suppress("UNUSED_VARIABLE")
    val aa6 = imv.MemberPtrDerived
    @Suppress("UNUSED_VARIABLE")
    val aa7 = imv.MemberMatrixDerived

    @Suppress("UNUSED_VARIABLE")
    val sa4 = InheritedMemberVars.StaticMemberValueDerived
    @Suppress("UNUSED_VARIABLE")
    val sa5 = InheritedMemberVars.StaticMemberArrayDerived
    @Suppress("UNUSED_VARIABLE")
    val sa6 = InheritedMemberVars.StaticMemberPtrDerived
    @Suppress("UNUSED_VARIABLE")
    val sa7 = InheritedMemberVars.StaticMemberMatrixDerived

    @Suppress("UNUSED_VARIABLE")
    val ga4 = assign_const.GlobalValueDerived
    @Suppress("UNUSED_VARIABLE")
    val ga5 = assign_const.GlobalArrayDerived
    @Suppress("UNUSED_VARIABLE")
    val ga6 = assign_const.GlobalPtrDerived
    @Suppress("UNUSED_VARIABLE")
    val ga7 = assign_const.GlobalMatrixDerived

    // These will have getters and setters
    @Suppress("UNUSED_VARIABLE")
    val a7v = imv.MemberValueDerivedSettable
    imv.MemberValueDerivedSettable = a7v
    @Suppress("UNUSED_VARIABLE")
    val a8 = imv.MemberArrayDerivedSettable
    imv.MemberArrayDerivedSettable = a8
    @Suppress("UNUSED_VARIABLE")
    val a9 = imv.MemberPtrDerivedSettable
    imv.MemberPtrDerivedSettable = a9
    @Suppress("UNUSED_VARIABLE")
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
    @Suppress("UNUSED_VARIABLE")
    val mpv1 = m.MemberValue
    @Suppress("UNUSED_VARIABLE")
    val mpv2 = m.MemberArray
    @Suppress("UNUSED_VARIABLE")
    val mpv3 = m.MemberPtr
    @Suppress("UNUSED_VARIABLE")
    val mpv4 = m.MemberMatrix

    @Suppress("UNUSED_VARIABLE")
    val smpv1 = StaticMembersMemberVars.StaticMemberValue
    @Suppress("UNUSED_VARIABLE")
    val smpv2 = StaticMembersMemberVars.StaticMemberArray
    @Suppress("UNUSED_VARIABLE")
    val smpv3 = StaticMembersMemberVars.StaticMemberPtr
    @Suppress("UNUSED_VARIABLE")
    val smpv4 = StaticMembersMemberVars.StaticMemberMatrix

    @Suppress("UNUSED_VARIABLE")
    val gmpv1 = assign_const.GlobalMemberValue
    @Suppress("UNUSED_VARIABLE")
    val gmpv2 = assign_const.GlobalMemberArray
    @Suppress("UNUSED_VARIABLE")
    val gmpv3 = assign_const.GlobalMemberPtr
    @Suppress("UNUSED_VARIABLE")
    val gmpv4 = assign_const.GlobalMemberMatrix

    // Setters and getters available
    val smmvh = StaticMembersMemberVarsHolder()
    val member = smmvh.Member
    smmvh.Member = member

    val smmv = assign_const.GlobalStaticMembersMemberVars
    assign_const.GlobalStaticMembersMemberVars = smmv
}
