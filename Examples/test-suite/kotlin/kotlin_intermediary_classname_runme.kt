@file:JvmName("kotlin_intermediary_classname_runme")

import kotlin_intermediary_classname.*

fun main() {
    try {
        System.loadLibrary("kotlin_intermediary_classname")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // test the renamed module class is correctly named
    val d = kotlin_intermediary_classnameModule.maxdouble(10.0, 20.0)
    if (d != 20.0) throw RuntimeException("Test failed")

    // test the renamed intermediary class is correctly named
    val ptr = kotlin_intermediary_classname.new_vecdouble(10)
    kotlin_intermediary_classname.delete_vecdouble(ptr)
}
