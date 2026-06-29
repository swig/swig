@file:JvmName("cpp11_ref_qualifiers_runme")

import cpp11_ref_qualifiers.*

fun main() {
    try {
        System.loadLibrary("cpp11_ref_qualifiers")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val h = Host()

    // Basic testing
    h.h1()
    h.h2()
    h.h6()
    h.h7()

    h.h()

    // %feature testing
    val f = Features()
    if (f.F1() != "F1") throw RuntimeException("Fail")
    if (f.F2() != "F2") throw RuntimeException("Fail")
    if (f.F3() != "F3") throw RuntimeException("Fail")

    if (f.C1(0) != "C1") throw RuntimeException("Fail")
    if (f.C2(0) != "C2") throw RuntimeException("Fail")
    if (f.C3(0) != "C3") throw RuntimeException("Fail")

    // %rename testing
    val r = Renames()
    r.RR1()
    r.RR2()
    r.RR3()

    r.SS1(0)
    r.SS2(0)
    r.SS3(0)

    // Conversion operators
    var s: String?
    val co = ConversionOperators()
    s = co.StringConvertCopy()
    s = co.StringConvertMove()

    val co2 = ConversionOperators2()
    s = co2.StringConvertMove()
}
