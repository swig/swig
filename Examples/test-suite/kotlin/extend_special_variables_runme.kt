@file:JvmName("extend_special_variables_runme")

import extend_special_variables.*

fun verify(received: String?, expected: String) {
    if (received != expected)
        throw RuntimeException("Incorrect, received: " + received)
}

fun main() {
    try {
        System.loadLibrary("extend_special_variables")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val f = ForExtensionNewName()
    verify(f.extended_renamed(), "name:extended symname:extended_renamed wrapname: overname:__SWIG_0 decl:ForExtension::extended() fulldecl:char const * ForExtension::extended() parentclasssymname:ForExtensionNewName parentclassname:ForExtension")
    verify(f.extended_renamed(10), "name:extended symname:extended_renamed wrapname: overname:__SWIG_1 decl:ForExtension::extended(int) fulldecl:char const * ForExtension::extended(int) parentclasssymname:ForExtensionNewName parentclassname:ForExtension")
}
