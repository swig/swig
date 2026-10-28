@file:JvmName("li_cdata_runme")

import li_cdata.*

fun main() {
    try {
        System.loadLibrary("li_cdata")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val expected = "ABC\u0000abc"
    val s = expected.toByteArray(Charsets.UTF_8)
    val m = li_cdata.malloc(256)
    li_cdata.memmove(m, s)
    val ss = li_cdata.cdata(m, 7)
    val ssString = String(ss, Charsets.UTF_8)
    if (ssString != expected)
        throw RuntimeException("failed got: " + ssString)
}
