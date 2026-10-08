@file:JvmName("sizet_runme")

import sizet.*

fun main() {
    try {
        System.loadLibrary("sizet")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    var s: Long = 2000
    s = sizet.test1(s + 1)
    s = sizet.test2(s + 1)
    s = sizet.test3(s + 1)
    s = sizet.test4(s + 1)
    if (s != 2004L)
        throw RuntimeException("failed")
}
