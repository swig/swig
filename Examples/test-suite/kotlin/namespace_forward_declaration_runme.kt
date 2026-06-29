@file:JvmName("namespace_forward_declaration_runme")

import namespace_forward_declaration.*

fun main() {
    try {
        System.loadLibrary("namespace_forward_declaration")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val xxx = XXX()
    namespace_forward_declaration.testXXX1(xxx)
    namespace_forward_declaration.testXXX2(xxx)
    namespace_forward_declaration.testXXX3(xxx)
    val yyy = YYY()
    namespace_forward_declaration.testYYY1(yyy)
    namespace_forward_declaration.testYYY2(yyy)
    namespace_forward_declaration.testYYY3(yyy)
}
