@file:JvmName("rename_pcre_encoder_runme")

import rename_pcre_encoder.*

fun main() {
    try {
        System.loadLibrary("rename_pcre_encoder")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val w = SomeWidget()
    w.put_borderWidth(17)
    if (w.get_borderWidth() != 17)
        throw RuntimeException("Border with should be 17, not ${w.get_borderWidth()}")
    if (rename_pcre_encoder.StartINSAneAndUNSAvoryTraNSAtlanticRaNSAck() != 42)
        throw RuntimeException("Unexpected result of renamed function call")
}
