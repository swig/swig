@file:JvmName("cpp11_type_aliasing_runme")

import cpp11_type_aliasing.*

fun main() {
    try {
        System.loadLibrary("cpp11_type_aliasing")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val ht = GeneratorBase().target
    val x = ht!!.getValue()
    if (x.bits != 32)
        throw RuntimeException("Incorrect bits")
}
