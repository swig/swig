@file:JvmName("cpp11_raw_string_literals_runme")

import cpp11_raw_string_literals.*

fun main() {
    try {
        System.loadLibrary("cpp11_raw_string_literals")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    if (cpp11_raw_string_literals.L != 100)
        throw RuntimeException("failed!")

    if (cpp11_raw_string_literals.u8 != 100)
        throw RuntimeException("failed!")

    if (cpp11_raw_string_literals.u != 100)
        throw RuntimeException("failed!")

    if (UStruct.U != 100)
        throw RuntimeException("failed!")

    if (cpp11_raw_string_literals.R != 100)
        throw RuntimeException("failed!")

    if (cpp11_raw_string_literals.LR != 100)
        throw RuntimeException("failed!")

    if (cpp11_raw_string_literals.u8R != 100)
        throw RuntimeException("failed!")

    if (cpp11_raw_string_literals.uR != 100)
        throw RuntimeException("failed!")

    if (URStruct.UR != 100)
        throw RuntimeException("failed!")

    // aa and ff are std::wstring which the Kotlin module wraps as an opaque
    // SWIGTYPE_p_wstring (no String typemap), so only the char/string-typed
    // globals can be compared by value here.
    if (cpp11_raw_string_literals.bb != "UTF-8 string")
        throw RuntimeException("failed!")

    if (cpp11_raw_string_literals.xx != ")I'm an \"ascii\" \\ string.")
        throw RuntimeException("failed!")

    if (cpp11_raw_string_literals.ee != ")I'm an \"ascii\" \\ string.")
        throw RuntimeException("failed!")

    if (cpp11_raw_string_literals.gg != "I'm a \"raw UTF-8\" \\ string.")
        throw RuntimeException("failed!")

    if (cpp11_raw_string_literals.mm != ")I'm an \"ascii\" \\ string constant with multiple\n\nlines.")
        throw RuntimeException("failed!")
}
