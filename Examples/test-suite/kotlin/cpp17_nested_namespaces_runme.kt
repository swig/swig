@file:JvmName("cpp17_nested_namespaces_runme")

import cpp17_nested_namespaces.*

fun main() {
    try {
        System.loadLibrary("cpp17_nested_namespaces")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    A1Struct().A1Method()
    B1Struct().B1Method()
    C1Struct().C1Method()
    cpp17_nested_namespaces.createA1Struct().A1Method()
    cpp17_nested_namespaces.createB1Struct().B1Method()
    cpp17_nested_namespaces.createC1Struct().C1Method()

    B2Struct().B2Method()
    C2Struct().C2Method()
    cpp17_nested_namespaces.createB2Struct().B2Method()
    cpp17_nested_namespaces.createC2Struct().C2Method()

    B3Struct().B3Method()
    C3Struct().C3Method()
    cpp17_nested_namespaces.createB3Struct().B3Method()
    cpp17_nested_namespaces.createC3Struct().C3Method()
}
