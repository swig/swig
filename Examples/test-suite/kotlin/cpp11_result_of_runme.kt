@file:JvmName("cpp11_result_of_runme")

import cpp11_result_of.*

fun main() {
    try {
        System.loadLibrary("cpp11_result_of")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    var result = cpp11_result_of.test_result(cpp11_result_of.SQUARE, 3.0)
    if (result != 9.0)
        throw RuntimeException("test_result(square, 3.0) is not 9.0. Got: " + result)

    result = cpp11_result_of.test_result_alternative1(cpp11_result_of.SQUARE, 3.0)
    if (result != 9.0)
        throw RuntimeException("test_result_alternative1(square, 3.0) is not 9.0. Got: " + result)
}
