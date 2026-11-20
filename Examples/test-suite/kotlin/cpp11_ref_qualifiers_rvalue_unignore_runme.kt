@file:JvmName("cpp11_ref_qualifiers_rvalue_unignore_runme")

import cpp11_ref_qualifiers_rvalue_unignore.*

fun main() {
    try {
        System.loadLibrary("cpp11_ref_qualifiers_rvalue_unignore")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    RefQualifier().m1()
    RefQualifier().m2()
}
