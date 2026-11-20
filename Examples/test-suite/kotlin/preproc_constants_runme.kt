@file:JvmName("preproc_constants_runme")

import preproc_constants.*

fun main() {
    try {
        System.loadLibrary("preproc_constants")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    if (preproc_constants.CONST_STRING4 != "zer\u0000zer\u0000")
        throw RuntimeException("Failed")
}
