@file:JvmName("using_member_typedef_template_runme")

import using_member_typedef_template.*

fun check(got: Int, expected: Int) {
    if (got != expected)
        throw RuntimeException("Expected $expected but got $got")
}

fun main() {
    try {
        System.loadLibrary("using_member_typedef_template")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Each class member and each global function takes an Integer (a typedef chain
    // resolving to int) and returns it unchanged, so check the value survives.

    val a = UsingDerivedA()
    check(a.aa(11), 11)

    val b = UsingDerivedB()
    check(b.bb(21), 21)
    check(b.bbb(22), 22)

    val c = UsingDerivedC()
    check(c.cc(31), 31)
    check(c.ccc(32), 32)

    val d = UsingDerivedD()
    check(d.dd(41), 41)
    check(d.ddd(42), 42)

    val e = UsingDerivedE()
    check(e.ee(51), 51)
    check(e.eee(52), 52)

    val f = UsingDerivedF()
    check(f.ff(61), 61)
    check(f.fff(62), 62)

    val g = UsingDerivedG()
    check(g.gg(71), 71)
    check(g.ggg(72), 72)

    val h = UsingDerivedH()
    check(h.hh(81), 81)
    check(h.hhh(82), 82)

    val i = UsingDerivedI()
    check(i.ii(91), 91)
    check(i.iii(92), 92)

    check(using_member_typedef_template.a_tester(1), 1)
    check(using_member_typedef_template.b_tester(2), 2)
    check(using_member_typedef_template.c_tester(3), 3)
    check(using_member_typedef_template.d_tester(4), 4)
    check(using_member_typedef_template.e_tester(5), 5)
    check(using_member_typedef_template.f_tester(6), 6)
    check(using_member_typedef_template.g_tester(7), 7)
    check(using_member_typedef_template.h_tester(8), 8)
    check(using_member_typedef_template.i_tester(9), 9)
}
