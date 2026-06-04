@file:JvmName("cpp11_constexpr_runme")

import cpp11_constexpr.*

fun check(received: Int, expected: Int) {
    if (expected != received)
        throw RuntimeException("check failed, expected: " + expected + " received: " + received)
}

fun main() {
    try {
        System.loadLibrary("cpp11_constexpr")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    check(cpp11_constexpr.AAA, 10)
    check(cpp11_constexpr.BBB, 20)
    check(cpp11_constexpr.CCC(), 30)
    check(cpp11_constexpr.DDD(), 40)

    val ce = ConstExpressions(0)
    check(ConstExpressions.JJJ, 100)
    check(ConstExpressions.KKK, 200)
    check(ConstExpressions.LLL, 300)
    check(ce.MMM(), 400)
    check(ce.NNN(), 500)
}
