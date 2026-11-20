@file:JvmName("cpp11_template_using_base_runme")

import cpp11_template_using_base.*

fun check(actual: String, expected: String) {
    if (actual != expected)
        throw RuntimeException("expected '" + expected + "' but got '" + actual + "'")
}

fun main() {
    try {
        System.loadLibrary("cpp11_template_using_base")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val d = DerivedInt()
    check(d.call(7), "Int:7")

    // Inheriting constructor: using I::I; brings IntCase(int) into DerivedInt
    val d10 = DerivedInt(10)
    check(d10.call(7), "Int:17")

    val o = OverloadedIntDouble()
    check(o.call(7), "Int:7")
    check(o.call(7.5), "Double:7.500000")
}
