@file:JvmName("nspace_interface_runme")

import nspace_interfacePackage.A.*

fun assertEq(s1: String, s2: String) {
    if (s1 != s2)
        throw RuntimeException("assertion failure. " + s1 + " != " + s2)
}

fun main() {
    try {
        System.loadLibrary("nspace_interface")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val impl = nspace_interfacePackage.A.Implementer()

    assertEq(impl.Method(), "Implemented A::B::Interface::Method")
}
