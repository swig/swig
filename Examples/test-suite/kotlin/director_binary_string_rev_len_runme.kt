@file:JvmName("director_binary_string_rev_len_runme")

import director_binary_string_rev_len.*

class DirectorReverseLengthStringCallback : Callback() {
    override fun run(dataBufferAA: String?): Int {
        var ret = 0
        if (dataBufferAA != null) {
            for (i in 0 until dataBufferAA.length)
                ret += dataBufferAA[i].code * 2
        }
        return ret
    }
}

fun main() {
    try {
        System.loadLibrary("director_binary_string_rev_len")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val callback: Callback = DirectorReverseLengthStringCallback()
    val caller = Caller(callback)
    val sum = caller.call()

    if (sum != 9 * 2 * 8)
        throw RuntimeException("Unexpected sum: " + sum)
}
