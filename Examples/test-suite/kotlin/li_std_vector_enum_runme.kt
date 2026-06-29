@file:JvmName("li_std_vector_enum_runme")

import li_std_vector_enum.*

fun check(a: Int, b: Int) {
    if (a != b)
        throw RuntimeException("values don't match")
}

fun main() {
    try {
        System.loadLibrary("li_std_vector_enum")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val ev = EnumVector()

    check(ev.nums!![0].swigValue, 10)
    check(ev.nums!![1].swigValue, 20)
    check(ev.nums!![2].swigValue, 30)
}
