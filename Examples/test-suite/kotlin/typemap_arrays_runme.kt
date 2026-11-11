@file:JvmName("typemap_arrays_runme")

import typemap_arrays.*

fun main() {
    try {
        System.loadLibrary("typemap_arrays")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    if (typemap_arrays.sumA(null) != 60)
        throw RuntimeException("Sum is wrong")
}
