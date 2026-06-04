@file:JvmName("director_binary_string_runme")

import director_binary_string.*

class DirectorBinaryStringCallback : Callback() {
    override fun run(dataBufferAA: String?, dataBufferBB: String?): Int {
        var ret = 0
        if (dataBufferAA != null) {
            for (i in 0 until dataBufferAA.length)
                ret += dataBufferAA[i].code * 2
        }

        if (dataBufferBB != null) {
            for (i in 0 until dataBufferBB.length) {
                ret += dataBufferBB[i].code * 3
            }
        }
        return ret
    }

    override fun writeData(dataBufferAA: String?): Int {
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
        System.loadLibrary("director_binary_string")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val caller = Caller()
    var callback: Callback = DirectorBinaryStringCallback()
    caller.setCallback(callback)
    val sum = caller.call()
    val sumData = caller.callWriteData()
    caller.delCallback()

    if (sum != 9 * 2 * 8 + 13 * 3 * 5)
        throw RuntimeException("Unexpected sum: " + sum)

    if (sumData != 9 * 2 * 8)
        throw RuntimeException("Unexpected sumData: " + sumData)

    Callback().run(null, null)
    callback = DirectorBinaryStringCallback()
    caller.setCallback(callback)
    caller.call_null()
}
