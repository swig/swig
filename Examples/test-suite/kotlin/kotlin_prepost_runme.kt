@file:JvmName("kotlin_prepost_runme")

import kotlin_prepost.*

fun assertEqual(d1: Double, d2: Double) {
    if (d1 != d2)
        throw RuntimeException("assertion failure. " + d1 + " != " + d2)
}

fun main() {
    try {
        System.loadLibrary("kotlin_prepost")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Unlike the Java test (checked InstantiationException), Kotlin has no checked
    // exceptions. The pre code throws a RuntimeException at runtime when null is passed.
    var caught = false
    try {
        val ppt = PrePostThrows(null, true)
    } catch (e: RuntimeException) {
        caught = true
    }
    if (!caught)
        throw RuntimeException("expected RuntimeException from pre typemap was not thrown")

    // Exercise the pre/post kin typemap: globalfunction takes a DoubleArray (kstype) and
    // the post code copies the populated DoubleVector contents back into the array.
    val v = DoubleArray(3)
    if (!kotlin_prepost.globalfunction(v))
        throw RuntimeException("globalfunction returned false")
    assertEqual(v[0], 0.0)
    assertEqual(v[1], 1.1)
    assertEqual(v[2], 2.2)
}
