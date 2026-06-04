@file:JvmName("template_using_member_default_arg_runme")

import template_using_member_default_arg.*

fun main() {
    try {
        System.loadLibrary("template_using_member_default_arg")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val a = ThingADerivedInt()
    a.describeA()
    val b = ThingBDerivedInt()
    b.describeB()
}
