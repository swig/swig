@file:JvmName("char_binary_rev_len_runme")

import char_binary_rev_len.*

fun main() {
    try {
        System.loadLibrary("char_binary_rev_len")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val t = Test()

    val hile = "hile"
    if (t.strlen(hile) != 4L)
        throw RuntimeException("bad multi-arg typemap 1")

    val hil0 = "hil\u0000"
    if (t.strlen(hil0) != 4L)
        throw RuntimeException("bad multi-arg typemap 2")

    val t2 = Test(hile)
    if (t2.getisize() != 4L)
        throw RuntimeException("bad multi-arg typemap 3")

    if (t2.strlen("hil\u0000a") != 5L)
        throw RuntimeException("bad multi-arg typemap 4")
}
