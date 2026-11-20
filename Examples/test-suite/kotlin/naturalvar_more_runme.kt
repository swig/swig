@file:JvmName("naturalvar_more_runme")

import naturalvar_more.*

fun main() {
    try {
        System.loadLibrary("naturalvar_more")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val s = S()
    if (s.const_string_member != "initial string value")
        throw RuntimeException("Test 1 fail")
    s.string_member = "some member value"
    if (s.string_member != "some member value")
        throw RuntimeException("Test 2 fail")
}
