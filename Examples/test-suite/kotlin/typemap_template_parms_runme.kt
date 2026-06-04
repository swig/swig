@file:JvmName("typemap_template_parms_runme")

import typemap_template_parms.*

fun main() {
    try {
        System.loadLibrary("typemap_template_parms")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val xint = Xint()
    xint.bake()
    xint.make()
    xint.lake()
    xint.rake()
    xint.take()
}
