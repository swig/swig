@file:JvmName("curiously_recurring_template_pattern_runme")

import curiously_recurring_template_pattern.*

fun main() {
    try {
        System.loadLibrary("curiously_recurring_template_pattern")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val d = Derived()
    d.setBase1Param(1).setDerived1Param(10).setDerived2Param(20).setBase2Param(2)

    if (d.getBase1Param() != 1)
        throw RuntimeException("fail")
    if (d.getDerived1Param() != 10)
        throw RuntimeException("fail")
    if (d.getBase2Param() != 2)
        throw RuntimeException("fail")
    if (d.getDerived2Param() != 20)
        throw RuntimeException("fail")
}
