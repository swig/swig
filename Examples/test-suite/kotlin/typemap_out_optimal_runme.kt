@file:JvmName("typemap_out_optimal_runme")

import typemap_out_optimal.*

fun main() {
    try {
        System.loadLibrary("typemap_out_optimal")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    XX.trace = false
    run {
        val x = XX.create()
        x.delete()
    }
    run {
        val x = XX.createConst()
        x.delete()
    }
}
