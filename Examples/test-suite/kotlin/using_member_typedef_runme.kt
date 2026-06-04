@file:JvmName("using_member_typedef_runme")

import using_member_typedef.*

fun check(got: Int, expected: Int) {
    if (got != expected)
        throw RuntimeException("Expected $expected but got $got")
}

fun main() {
    try {
        System.loadLibrary("using_member_typedef")
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

    check(using_member_typedef.a_tester(1), 1)
    check(using_member_typedef.b_tester(2), 2)
    check(using_member_typedef.c_tester(3), 3)
    check(using_member_typedef.d_tester(4), 4)
    check(using_member_typedef.e_tester(5), 5)
    check(using_member_typedef.f_tester(6), 6)
    check(using_member_typedef.g_tester(7), 7)
}
