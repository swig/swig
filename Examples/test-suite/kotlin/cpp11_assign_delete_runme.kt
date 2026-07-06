@file:JvmName("cpp11_assign_delete_runme")

import cpp11_assign_delete.*

fun main() {
    try {
        System.loadLibrary("cpp11_assign_delete")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val mv = MemberVars()
    val mav = MemberArrayVars()

    // (1) Test directly non-assignable member variables
    // These will only have getters
    val a1 = mv.MemberPublic
    val a2 = mv.MemberProtected
    val a3 = mv.MemberPrivate

    val ma1 = mav.ArrayMemberPublic
    val ma2 = mav.ArrayMemberProtected
    val ma3 = mav.ArrayMemberPrivate

    // (2) Test indirectly non-assignable member variables via inheritance
    val imv = InheritedMemberVars()
    // These will only have getters
    val a4 = imv.MemberPublicDerived
    val a5 = imv.MemberProtectedDerived
    val a6 = imv.MemberPrivateDerived

    val sa4 = InheritedMemberVars.StaticMemberPublicDerived
    val sa5 = InheritedMemberVars.StaticMemberProtectedDerived
    val sa6 = InheritedMemberVars.StaticMemberPrivateDerived

    val ga4 = cpp11_assign_delete.GlobalPublicDerived
    val ga5 = cpp11_assign_delete.GlobalProtectedDerived
    val ga6 = cpp11_assign_delete.GlobalPrivateDerived

    // These will have getters and setters
    val a7 = imv.MemberPublicDerivedSettable
    imv.MemberPublicDerivedSettable = a7
    val a8 = imv.MemberProtectedDerivedSettable
    imv.MemberProtectedDerivedSettable = a8
    val a9 = imv.MemberPrivateDerivedSettable
    imv.MemberPrivateDerivedSettable = a9

    val sa7 = InheritedMemberVars.StaticMemberPublicDerivedSettable
    InheritedMemberVars.StaticMemberPublicDerivedSettable = sa7
    val sa8 = InheritedMemberVars.StaticMemberProtectedDerivedSettable
    InheritedMemberVars.StaticMemberProtectedDerivedSettable = sa8
    val sa9 = InheritedMemberVars.StaticMemberPrivateDerivedSettable
    InheritedMemberVars.StaticMemberPrivateDerivedSettable = sa9

    val ga7 = cpp11_assign_delete.GlobalPublicDerivedSettable
    cpp11_assign_delete.GlobalPublicDerivedSettable = ga7
    val ga8 = cpp11_assign_delete.GlobalProtectedDerivedSettable
    cpp11_assign_delete.GlobalProtectedDerivedSettable = ga8
    val ga9 = cpp11_assign_delete.GlobalPrivateDerivedSettable
    cpp11_assign_delete.GlobalPrivateDerivedSettable = ga9

    // (3) Test indirectly non-assignable member variables via classes that themselves have non-assignable member variables
    run {
        val m = MembersMemberVars()

        // These will only have getters
        val mpv1 = m.MemberPublic
        val mpv2 = m.MemberProtected
        val mpv3 = m.MemberPrivate

        val smpv1 = StaticMembersMemberVars.StaticMemberPublic
        val smpv2 = StaticMembersMemberVars.StaticMemberProtected
        val smpv3 = StaticMembersMemberVars.StaticMemberPrivate

        val gmpv1 = cpp11_assign_delete.GlobalMemberPublic
        val gmpv2 = cpp11_assign_delete.GlobalMemberProtected
        val gmpv3 = cpp11_assign_delete.GlobalMemberPrivate

        // Setters and getters available
        val smmvh = StaticMembersMemberVarsHolder()
        val member = smmvh.Member
        smmvh.Member = member

        val smmv = cpp11_assign_delete.GlobalStaticMembersMemberVars
        cpp11_assign_delete.GlobalStaticMembersMemberVars = smmv
    }

    // (4) Test indirectly non-assignable member variables via classes that themselves have non-assignable array member variables
    run {
        val m = MembersMemberArrayVars()

        // These will only have getters
        val mpv1 = m.MemberPublic
        val mpv2 = m.MemberProtected
        val mpv3 = m.MemberPrivate

        val smpv1 = StaticMembersMemberArrayVars.StaticMemberPublic
        val smpv2 = StaticMembersMemberArrayVars.StaticMemberProtected
        val smpv3 = StaticMembersMemberArrayVars.StaticMemberPrivate

        val gmpv1 = cpp11_assign_delete.GlobalArrayMemberPublic
        val gmpv2 = cpp11_assign_delete.GlobalArrayMemberProtected
        val gmpv3 = cpp11_assign_delete.GlobalArrayMemberPrivate

        // Setters and getters available
        val smmvh = StaticMembersMemberArrayVarsHolder()
        val member = smmvh.Member
        smmvh.Member = member

        val smmv = cpp11_assign_delete.GlobalStaticMembersMemberArrayVars
        cpp11_assign_delete.GlobalStaticMembersMemberArrayVars = smmv
    }

    // (5) Test indirectly non-assignable member variables via classes that themselves have non-assignable reference member variables
    run {
        val m = MembersMemberRefVars()

        // These will only have getters
        val mpv1 = m.MemberPublic
        val mpv2 = m.MemberProtected
        val mpv3 = m.MemberPrivate

        val smpv1 = StaticMembersMemberRefVars.StaticMemberPublic
        val smpv2 = StaticMembersMemberRefVars.StaticMemberProtected
        val smpv3 = StaticMembersMemberRefVars.StaticMemberPrivate

        val gmpv1 = cpp11_assign_delete.GlobalRefMemberPublic
        val gmpv2 = cpp11_assign_delete.GlobalRefMemberProtected
        val gmpv3 = cpp11_assign_delete.GlobalRefMemberPrivate

        // Setters and getters available
        val smmvh = StaticMembersMemberRefVarsHolder()
        val member = smmvh.Member
        smmvh.Member = member

        val smmv = cpp11_assign_delete.GlobalStaticMembersMemberRefVars
        cpp11_assign_delete.GlobalStaticMembersMemberRefVars = smmv
    }
}
