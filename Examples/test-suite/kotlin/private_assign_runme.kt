@file:JvmName("private_assign_runme")

import private_assign.*

fun main() {
    try {
        System.loadLibrary("private_assign")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val three = Three()
    @Suppress("UNUSED_VARIABLE")
    val tn = three.TwoNot
    @Suppress("UNUSED_VARIABLE")
    val ti = three.TwoIs
    three.TwoIs = TwoIsAssignableCopyable()
}
