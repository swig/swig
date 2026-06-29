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
    val tn = three.TwoNot
    val ti = three.TwoIs
    three.TwoIs = TwoIsAssignableCopyable()
}
