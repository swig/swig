@file:JvmName("typemap_namespace_runme")

import typemap_namespace.*

fun main() {
    try {
        System.loadLibrary("typemap_namespace")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    if (typemap_namespace.test1("hello") != "hello")
        throw RuntimeException("test1 failed")
    if (typemap_namespace.test2("hello") != "hello")
        throw RuntimeException("test2 failed")
}
