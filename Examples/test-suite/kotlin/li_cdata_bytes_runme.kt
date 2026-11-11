@file:JvmName("li_cdata_bytes_runme")

import li_cdata_bytes.*

fun main() {
    try {
        System.loadLibrary("li_cdata_bytes")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val m = li_cdata_bytes.predefStr()
    val s = li_cdata_bytes.cdata(m, 0x200)
    for (i in 0 until 0x100) {
        var v = s[i].toInt() and 0xFF
        if (v != i)
            throw RuntimeException("Wrong value " + v + " at index " + i)
        v = s[i + 0x100].toInt() and 0xFF
        if (v != i)
            throw RuntimeException("Wrong value " + v + " at index " + (i + 0x100))
    }
    for (i in 0 until 0x100) {
        val v = (0x100 - 1 - i).toByte()
        s[i] = v
        s[i + 0x100] = v
    }
    val m2 = li_cdata_bytes.malloc(0x200)
    li_cdata_bytes.memmove(m2, s)
    if (li_cdata_bytes.verifyBytes(m2) != 0)
        throw RuntimeException("verifyBytes fails")
    li_cdata_bytes.free(m2)
}
