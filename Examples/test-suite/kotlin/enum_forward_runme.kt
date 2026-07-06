@file:JvmName("enum_forward_runme")

import enum_forward.*

fun main() {
    try {
        System.loadLibrary("enum_forward")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    try {
        var f1 = enum_forward.get_enum1()
        f1 = enum_forward.test_function1(f1)
    } catch (e: IllegalArgumentException) {
    }

    try {
        var f2 = enum_forward.get_enum2()
        f2 = enum_forward.test_function2(f2)
    } catch (e: IllegalArgumentException) {
    }

    var f3 = enum_forward.get_enum3()
    f3 = enum_forward.test_function3(f3)
}
