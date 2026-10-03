@file:JvmName("constant_directive_runme")

import constant_directive.*

fun main() {
    try {
        System.loadLibrary("constant_directive")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    if (constant_directive.TYPE1_CONSTANT1._val != 1)
        throw RuntimeException("fail")
    if (constant_directive.TYPE1_CONSTANT2._val != 2)
        throw RuntimeException("fail")
    if (constant_directive.TYPE1_CONSTANT3!!._val != 3)
        throw RuntimeException("fail")
    if (constant_directive.TYPE1CONST_CONSTANT1!!._val != 1)
        throw RuntimeException("fail")
    if (constant_directive.TYPE1CPTR_CONSTANT1!!._val != 1)
        throw RuntimeException("fail")
}
