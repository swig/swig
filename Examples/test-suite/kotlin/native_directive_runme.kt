@file:JvmName("native_directive_runme")

import native_directive.*

fun main() {
    try {
        System.loadLibrary("native_directive")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val s = "abc.DEF-123"
    if (native_directive.CountAlphas(s) != 6)
        throw RuntimeException("CountAlphas failed")
    // CountAlphaCharacters is provided by a Java-only %native directive (#if defined(SWIGJAVA))
    // and is therefore not generated for the Kotlin module.
}
