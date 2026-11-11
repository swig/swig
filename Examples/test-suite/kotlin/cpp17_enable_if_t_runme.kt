@file:JvmName("cpp17_enable_if_t_runme")

import cpp17_enable_if_t.*

fun main() {
    try {
        System.loadLibrary("cpp17_enable_if_t")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    if (cpp17_enable_if_t.enableif5(10, 20) != 30)
        throw RuntimeException("enableif5 not working")
}
