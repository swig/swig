@file:JvmName("using_extend_flatten_runme")

import using_extend_flatten.*

fun main() {
    try {
        System.loadLibrary("using_extend_flatten")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val ed = ExtendDerived()
    ed.one()
    ed.two()
    ed.three()
}
