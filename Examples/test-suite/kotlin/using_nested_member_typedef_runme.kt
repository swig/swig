@file:JvmName("using_nested_member_typedef_runme")

import using_nested_member_typedef.*

fun check(got: Int, expected: Int) {
    if (got != expected)
        throw RuntimeException("Expected $expected but got $got")
}

fun main() {
    try {
        System.loadLibrary("using_nested_member_typedef")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val d = UsingDerived()
    check(d.hh(81), 81)

    val deep = UsingDerivedDeep()
    check(deep.jj(81), 81)
}
