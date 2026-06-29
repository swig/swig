@file:JvmName("cpp11_std_function_runme")

import cpp11_std_function.*

fun main() {
    try {
        System.loadLibrary("cpp11_std_function")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val fn = cpp11_std_function.pass_checker(420)

    // invoke functor via call method
    var result = fn.call(420, "Petka")
    if (!result)
        throw RuntimeException("Petka 420 should be true")

    result = fn.call(419, "Chapai")
    if (result)
        throw RuntimeException("Chapai 419 should be false")

    // call wrapper
    result = cpp11_std_function.call_function(fn, 420, "Petka")
    if (!result)
        throw RuntimeException("Petka 420 should be true")

    result = cpp11_std_function.call_function(fn, 419, "Chapai")
    if (result)
        throw RuntimeException("Chapai 419 should be false")

    // NULL handling
    var passed = false
    try {
        @Suppress("UNCHECKED_CAST")
        val nullLambda = null as cpp_lambda
        cpp11_std_function.call_function(nullLambda, 420, "Petka")
    } catch (e: RuntimeException) {
        passed = true
    }
    if (!passed)
        throw RuntimeException("call_function accepted invalid argument")
}
