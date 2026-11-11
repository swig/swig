@file:JvmName("template_type_collapse_runme")

import template_type_collapse.*

fun main() {
    try {
        System.loadLibrary("template_type_collapse")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val i = 1234
    val ci: ConsterInt = DerivedConsterInt()
    ci.cccc1(i)
    ci.cccc2(i)
    ci.cccc3(i)
    ci.cccc4(i)

    val dci = DerivedConsterInt()
    dci.dddd(i)
}
