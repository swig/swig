@file:JvmName("inctest_runme")

import inctest.*

fun main() {
    try {
        System.loadLibrary("inctest")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val things = MY_THINGS()
    val i = 0
    things.IntegerMember = i
    val d = things.DoubleMember
}
