@file:JvmName("memberin_extend_runme")

import memberin_extend.*

fun main() {
    try {
        System.loadLibrary("memberin_extend")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val em1 = ExtendMe()
    val em2 = ExtendMe()
    em1.thing = "em1thing"
    em2.thing = "em2thing"
    if (em1.thing != "em1thing")
        throw RuntimeException("wrong: " + em1.thing)
    if (em2.thing != "em2thing")
        throw RuntimeException("wrong: " + em2.thing)
}
