@file:JvmName("default_constructor_runme")

import default_constructor.*

fun main() {
    try {
        System.loadLibrary("default_constructor")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // calling protected destructor test
    try {
        val g = G()
        g.delete()
        throw RuntimeException("Protected destructor exception should have been thrown")
    } catch (e: UnsupportedOperationException) {
    }
}
