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
    val pint = ap.PublicMember
    ap.PublicMember = assign_reference.getGlobalIntRef()

    val mv = MemberVars()

    // (1) Test directly non-assignable member variables
    // These will only have getters
    val a1 = mv.MemberPublic
    val a2 = mv.MemberProtected
    val a3 = mv.MemberPrivate

    // (2) Test indirectly non-assignable member variables via inheritance
    val imv = InheritedMemberVars()
    // These will only have getters
    val a4 = imv.MemberPublicDerived
    val a5 = imv.MemberProtectedDerived
    val a6 = imv.MemberPrivateDerived

    val sa4 = InheritedMemberVars.StaticMemberPublicDerived
    val sa5 = InheritedMemberVars.StaticMemberProtectedDerived
    val sa6 = InheritedMemberVars.StaticMemberPrivateDerived

    val ga4 = assign_reference.GlobalPublicDerived
    val ga5 = assign_reference.GlobalProtectedDerived
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
    val mpv1 = m.MemberPublic
    val mpv2 = m.MemberProtected
    val mpv3 = m.MemberPrivate

    val smpv1 = StaticMembersMemberVars.StaticMemberPublic
    val smpv2 = StaticMembersMemberVars.StaticMemberProtected
    val smpv3 = StaticMembersMemberVars.StaticMemberPrivate

    val gmpv1 = assign_reference.GlobalMemberPublic
    val gmpv2 = assign_reference.GlobalMemberProtected
    val gmpv3 = assign_reference.GlobalMemberPrivate

    // Setters and getters available
    val smmvh = StaticMembersMemberVarsHolder()
    val member = smmvh.Member
    smmvh.Member = member

    val smmv = assign_reference.GlobalStaticMembersMemberVars
    assign_reference.GlobalStaticMembersMemberVars = smmv
}
