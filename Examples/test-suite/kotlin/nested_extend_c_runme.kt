@file:JvmName("nested_extend_c_runme")

import nested_extend_c.*

fun main() {
    try {
        System.loadLibrary("nested_extend_c")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    run {
        val hi = hiA()
        if (hi.hi_extend() != 'h')
            throw RuntimeException("test failed")
    }
    run {
        val low = lowA()
        if (low.low_extend() != 99)
            throw RuntimeException("test failed")
    }

    run {
        val hi = hiB()
        if (hi.hi_extend() != 'h')
            throw RuntimeException("test failed")
    }
    run {
        val low = lowB()
        if (low.low_extend() != 99)
            throw RuntimeException("test failed")
    }
    run {
        val foobar = FOO_bar()
        foobar.d = 1234
        if (foobar.d != 1234)
            throw RuntimeException("test failed")
        foobar.bar_extend()
    }
}
