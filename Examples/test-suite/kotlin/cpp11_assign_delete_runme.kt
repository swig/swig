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
    @Suppress("UNUSED_VARIABLE")
    val a1 = mv.MemberPublic
    @Suppress("UNUSED_VARIABLE")
    val a2 = mv.MemberProtected
    @Suppress("UNUSED_VARIABLE")
    val a3 = mv.MemberPrivate

    @Suppress("UNUSED_VARIABLE")
    val ma1 = mav.ArrayMemberPublic
    @Suppress("UNUSED_VARIABLE")
    val ma2 = mav.ArrayMemberProtected
    @Suppress("UNUSED_VARIABLE")
    val ma3 = mav.ArrayMemberPrivate

    // (2) Test indirectly non-assignable member variables via inheritance
    val imv = InheritedMemberVars()
    // These will only have getters
    @Suppress("UNUSED_VARIABLE")
    val a4 = imv.MemberPublicDerived
    @Suppress("UNUSED_VARIABLE")
    val a5 = imv.MemberProtectedDerived
    @Suppress("UNUSED_VARIABLE")
    val a6 = imv.MemberPrivateDerived

    @Suppress("UNUSED_VARIABLE")
    val sa4 = InheritedMemberVars.StaticMemberPublicDerived
    @Suppress("UNUSED_VARIABLE")
    val sa5 = InheritedMemberVars.StaticMemberProtectedDerived
    @Suppress("UNUSED_VARIABLE")
    val sa6 = InheritedMemberVars.StaticMemberPrivateDerived

    @Suppress("UNUSED_VARIABLE")
    val ga4 = cpp11_assign_delete.GlobalPublicDerived
    @Suppress("UNUSED_VARIABLE")
    val ga5 = cpp11_assign_delete.GlobalProtectedDerived
    @Suppress("UNUSED_VARIABLE")
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
        @Suppress("UNUSED_VARIABLE")
        val mpv1 = m.MemberPublic
        @Suppress("UNUSED_VARIABLE")
        val mpv2 = m.MemberProtected
        @Suppress("UNUSED_VARIABLE")
        val mpv3 = m.MemberPrivate

        @Suppress("UNUSED_VARIABLE")
        val smpv1 = StaticMembersMemberVars.StaticMemberPublic
        @Suppress("UNUSED_VARIABLE")
        val smpv2 = StaticMembersMemberVars.StaticMemberProtected
        @Suppress("UNUSED_VARIABLE")
        val smpv3 = StaticMembersMemberVars.StaticMemberPrivate

        @Suppress("UNUSED_VARIABLE")
        val gmpv1 = cpp11_assign_delete.GlobalMemberPublic
        @Suppress("UNUSED_VARIABLE")
        val gmpv2 = cpp11_assign_delete.GlobalMemberProtected
        @Suppress("UNUSED_VARIABLE")
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
        @Suppress("UNUSED_VARIABLE")
        val mpv1 = m.MemberPublic
        @Suppress("UNUSED_VARIABLE")
        val mpv2 = m.MemberProtected
        @Suppress("UNUSED_VARIABLE")
        val mpv3 = m.MemberPrivate

        @Suppress("UNUSED_VARIABLE")
        val smpv1 = StaticMembersMemberArrayVars.StaticMemberPublic
        @Suppress("UNUSED_VARIABLE")
        val smpv2 = StaticMembersMemberArrayVars.StaticMemberProtected
        @Suppress("UNUSED_VARIABLE")
        val smpv3 = StaticMembersMemberArrayVars.StaticMemberPrivate

        @Suppress("UNUSED_VARIABLE")
        val gmpv1 = cpp11_assign_delete.GlobalArrayMemberPublic
        @Suppress("UNUSED_VARIABLE")
        val gmpv2 = cpp11_assign_delete.GlobalArrayMemberProtected
        @Suppress("UNUSED_VARIABLE")
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
        @Suppress("UNUSED_VARIABLE")
        val mpv1 = m.MemberPublic
        @Suppress("UNUSED_VARIABLE")
        val mpv2 = m.MemberProtected
        @Suppress("UNUSED_VARIABLE")
        val mpv3 = m.MemberPrivate

        @Suppress("UNUSED_VARIABLE")
        val smpv1 = StaticMembersMemberRefVars.StaticMemberPublic
        @Suppress("UNUSED_VARIABLE")
        val smpv2 = StaticMembersMemberRefVars.StaticMemberProtected
        @Suppress("UNUSED_VARIABLE")
        val smpv3 = StaticMembersMemberRefVars.StaticMemberPrivate

        @Suppress("UNUSED_VARIABLE")
        val gmpv1 = cpp11_assign_delete.GlobalRefMemberPublic
        @Suppress("UNUSED_VARIABLE")
        val gmpv2 = cpp11_assign_delete.GlobalRefMemberProtected
        @Suppress("UNUSED_VARIABLE")
        val gmpv3 = cpp11_assign_delete.GlobalRefMemberPrivate

        // Setters and getters available
        val smmvh = StaticMembersMemberRefVarsHolder()
        val member = smmvh.Member
        smmvh.Member = member

        val smmv = cpp11_assign_delete.GlobalStaticMembersMemberRefVars
        cpp11_assign_delete.GlobalStaticMembersMemberRefVars = smmv
    }
}
