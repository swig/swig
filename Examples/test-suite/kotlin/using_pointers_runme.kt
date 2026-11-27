@file:JvmName("using_pointers_runme")

import using_pointers.*

fun main() {
    try {
        System.loadLibrary("using_pointers")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val f = FooBar()
    var pass = true
    try {
        f.exception_spec(1)
        pass = false
    } catch (e: RuntimeException) {
    }
    if (!pass) throw RuntimeException("Missed exception 1")
    try {
        f.exception_spec(2)
        pass = false
    } catch (e: RuntimeException) {
    }
    if (!pass) throw RuntimeException("Missed exception 2")
}
