@file:JvmName("smart_pointer_ignore_runme")

import smart_pointer_ignore.*

fun main() {
    try {
        System.loadLibrary("smart_pointer_ignore")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val d = smart_pointer_ignore.makeDerived()
    d.baseMethod()
    d.derivedMethod()
}
