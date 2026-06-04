@file:JvmName("cpp20_variable_templates_runme")

import cpp20_variable_templates.*

fun main() {
    try {
        System.loadLibrary("cpp20_variable_templates")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // int satisfies 't + t', NotAddable doesn't.
    if (!cpp20_variable_templates.addable_int)
        throw RuntimeException("addable_int")
    if (cpp20_variable_templates.addable_notaddable)
        throw RuntimeException("addable_notaddable")
}
