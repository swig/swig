@file:JvmName("cpp14_variable_templates_runme")

import cpp14_variable_templates.*

fun main() {
    try {
        System.loadLibrary("cpp14_variable_templates")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Variable template instantiations are wrapped as read only variables holding the value
    if (cpp14_variable_templates.bits_in_char != 8)
        throw RuntimeException("bits_in_char")
    if (cpp14_variable_templates.factorial_5 != 120)
        throw RuntimeException("factorial_5")
    if (cpp14_variable_templates.factorial_10 != 3628800)
        throw RuntimeException("factorial_10")
}
