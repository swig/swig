@file:JvmName("assign_reference_runme")

import assign_reference.*

fun main() {
    try {
        System.loadLibrary("assign_reference")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val ap = AssignPublic()
    @Suppress("UNUSED_VARIABLE")
    val pint = ap.PublicMember
    ap.PublicMember = assign_reference.getGlobalIntRef()

    val mv = MemberVars()

    // (1) Test directly non-assignable member variables
    // These will only have getters
    @Suppress("UNUSED_VARIABLE")
    val a1 = mv.MemberPublic
    @Suppress("UNUSED_VARIABLE")
    val a2 = mv.MemberProtected
    @Suppress("UNUSED_VARIABLE")
    val a3 = mv.MemberPrivate

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
    val ga4 = assign_reference.GlobalPublicDerived
    @Suppress("UNUSED_VARIABLE")
    val ga5 = assign_reference.GlobalProtectedDerived
    @Suppress("UNUSED_VARIABLE")
    val ga6 = assign_reference.GlobalPrivateDerived

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

    val ga7 = assign_reference.GlobalPublicDerivedSettable
    assign_reference.GlobalPublicDerivedSettable = ga7
    val ga8 = assign_reference.GlobalProtectedDerivedSettable
    assign_reference.GlobalProtectedDerivedSettable = ga8
    val ga9 = assign_reference.GlobalPrivateDerivedSettable
    assign_reference.GlobalPrivateDerivedSettable = ga9

    // (3) Test indirectly non-assignable member variables via classes that themselves have non-assignable member variables
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
    val gmpv1 = assign_reference.GlobalMemberPublic
    @Suppress("UNUSED_VARIABLE")
    val gmpv2 = assign_reference.GlobalMemberProtected
    @Suppress("UNUSED_VARIABLE")
    val gmpv3 = assign_reference.GlobalMemberPrivate

    // Setters and getters available
    val smmvh = StaticMembersMemberVarsHolder()
    val member = smmvh.Member
    smmvh.Member = member

    val smmv = assign_reference.GlobalStaticMembersMemberVars
    assign_reference.GlobalStaticMembersMemberVars = smmv
}
