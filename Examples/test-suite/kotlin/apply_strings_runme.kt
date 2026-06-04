@file:JvmName("apply_strings_runme")

import apply_strings.*

val TEST_MESSAGE = "A message from target language to the C++ world and back again."

fun main() {
    try {
        System.loadLibrary("apply_strings")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    if (apply_strings.UCharFunction(TEST_MESSAGE) != TEST_MESSAGE) throw RuntimeException("UCharFunction failed")
    if (apply_strings.SCharFunction(TEST_MESSAGE) != TEST_MESSAGE) throw RuntimeException("SCharFunction failed")
    val pChar = apply_strings.CharFunction(null)
    if (pChar != null) throw RuntimeException("CharFunction failed")
}
