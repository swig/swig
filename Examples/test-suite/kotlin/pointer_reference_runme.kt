@file:JvmName("pointer_reference_runme")

import pointer_reference.*

fun main() {
    try {
        System.loadLibrary("pointer_reference")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val s = pointer_reference.get()
    if (s!!.value != 10) throw RuntimeException("get test failed")

    val ss = Struct(20)
    pointer_reference.set(ss)
    if (Struct.instance!!.value != 20) throw RuntimeException("set test failed")

    if (pointer_reference.overloading(1) != 111) throw RuntimeException("overload test 1 failed")
    if (pointer_reference.overloading(ss) != 222) throw RuntimeException("overload test 2 failed")
}
