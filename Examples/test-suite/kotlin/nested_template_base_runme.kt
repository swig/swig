@file:JvmName("nested_template_base_runme")

import nested_template_base.*

fun main() {
    try {
        System.loadLibrary("nested_template_base")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val ois = InnerS(123)
    val oic = InnerC()

    // Check base method is available
    if (oic.outer(ois)._val != 123)
        throw RuntimeException("Wrong value calling outer")

    // Check non-derived class using base class
    if (oic.innerc().outer(ois)._val != 123)
        throw RuntimeException("Wrong value calling innerc")
}
