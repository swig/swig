@file:JvmName("derived_nested_runme")

import derived_nested.*

fun main() {
    try {
        System.loadLibrary("derived_nested")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val outer = BB()
    val d = BB.DD()
    val e = BB.EE()
    outer.ff_instance!!.z = outer.ff_instance!!.x
    outer.useEE(e)
}
