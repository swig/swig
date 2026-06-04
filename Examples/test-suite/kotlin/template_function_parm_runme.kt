@file:JvmName("template_function_parm_runme")

import template_function_parm.*

fun main() {
    try {
        System.loadLibrary("template_function_parm")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val vi = VectorInt()
    vi.add(10)
    vi.add(20)
    vi.add(30)

    val myc = MyC()
    val sum = myc.take_function(template_function_parm.accumulate_integers, vi)
    if (sum != 60)
        throw RuntimeException("Expected sum of 60, got " + sum)
}
