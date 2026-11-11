@file:JvmName("cpp14_generic_lambda_runme")

import cpp14_generic_lambda.*

fun main() {
    try {
        System.loadLibrary("cpp14_generic_lambda")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Single auto parameter.
    if (cpp14_generic_lambda.run_twice(5) != 10)
        throw RuntimeException("run_twice(5)")

    // Two auto parameters.
    if (cpp14_generic_lambda.run_add(3, 4) != 7)
        throw RuntimeException("run_add(3, 4)")
}
