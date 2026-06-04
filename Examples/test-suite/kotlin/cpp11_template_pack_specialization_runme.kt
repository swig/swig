@file:JvmName("cpp11_template_pack_specialization_runme")

import cpp11_template_pack_specialization.*

fun check(actual: Int, expected: Int, label: String) {
    if (actual != expected)
        throw RuntimeException(label + " expected " + expected + " got " + actual)
}

fun check(actual: Double, expected: Double, label: String) {
    if (actual != expected)
        throw RuntimeException(label + " expected " + expected + " got " + actual)
}

fun check(actual: String, expected: String, label: String) {
    if (actual != expected)
        throw RuntimeException(label + " expected " + expected + " got " + actual)
}

fun main() {
    try {
        System.loadLibrary("cpp11_template_pack_specialization")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val spi = SomeParmsInt()
    spi.primary_method()

    val spp = SomeParmsNoParms()
    spp.partial_method()

    val sps = SomeParmsString()
    sps.partial_method("hello")

    val spid = SomeParmsIntDouble()
    spid.partial_method(10, 11.1)

    val sp2i = SomeParms2PackInt()
    sp2i.partial2_methodC(20)

    val sp2id = SomeParms2PackIntDouble()
    sp2id.partial2_methodA(11.1)
    sp2id.partial2_methodB(55, 11.1)
    sp2id.partial2_methodC(55)

    val sp2idf = SomeParms2PackIntDoubleFloat()
    sp2idf.partial2_methodA(11.1, 22.2f)
    sp2idf.partial2_methodB(55, 11.1, 22.2f)
    sp2idf.partial2_methodC(55)

    // StdFunction testing
    val f_int = StdFunctionIntInt()
    check(f_int.call(10, 20), 30, "f_int.call(10, 20)")
    check(f_int.call_operator(20, 30), 50, "f_int.call_operator(20, 30)")

    val f_int0 = StdFunctionVoid()
    check(f_int0.call(), 0, "f_int0.call()")
    check(f_int0.call_operator(), 0, "f_int0.call_operator()")

    val f_int1 = StdFunctionInt()
    check(f_int1.call(7), 7, "f_int1.call(7)")
    check(f_int1.call_operator(7), 7, "f_int1.call_operator(7)")

    val f_double = StdFunctionDoubleDouble()
    check(f_double.call(1.5, 2.25), 3.75, "f_double.call(1.5, 2.25)")
    check(f_double.call_operator(1.5, 2.25), 3.75, "f_double.call_operator(1.5, 2.25)")

    val f_string = StdFunctionStringString()
    check(f_string.call("ab", "cd"), "abcd", "f_string.call(\"ab\", \"cd\")")
    check(f_string.call_operator("ab", "cd"), "abcd", "f_string.call_operator(\"ab\", \"cd\")")

    val f_mixed = StdFunctionMixed()
    check(f_mixed.call(1, 2.0, 3), 6, "f_mixed.call(1, 2.0, 3)")
    check(f_mixed.call_operator(1, 2.0, 3), 6, "f_mixed.call_operator(1, 2.0, 3)")
}
