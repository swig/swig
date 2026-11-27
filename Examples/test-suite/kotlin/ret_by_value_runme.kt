@file:JvmName("ret_by_value_runme")

import ret_by_value.*

fun main() {
    try {
        System.loadLibrary("ret_by_value")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Get the test class. Note that this constructor will ensure that the memory created
    // in the wrapper is owned by the test class.
    val tst = ret_by_value.get_test()

    if (tst.myInt != 100 || tst.myShort.toInt() != 200) {
        System.err.println("Runtime test failed. myInt=" + tst.myInt + " myShort=" + tst.myShort)
        kotlin.system.exitProcess(1)
    }

    // Delete memory manually, it should not be deleted again by the test class finalizer
    tst.delete()
}
