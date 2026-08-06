@file:JvmName("cpp11_using_functor_runme")

import cpp11_using_functor.*

fun main() {
    try {
        System.loadLibrary("cpp11_using_functor")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Overloaded helper built from two concrete functor base classes (C++11 form).
    // operator() is renamed to call() by %rename, giving an overloaded proxy method.
    val ov = OverloadedIntDouble()
    if (ov.call(7) != "Int:7")
        throw RuntimeException("ov.call(7)")
    if (ov.call(2.5) != "Double:2.500000")
        throw RuntimeException("ov.call(2.5)")
}
