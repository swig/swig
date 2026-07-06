@file:JvmName("imports_runme")

import imports.*

fun main() {
    try {
        System.loadLibrary("imports_a")
        System.loadLibrary("imports_b")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val b = B()
    b.hello() // call member function in A which is in a different SWIG generated library.
}
