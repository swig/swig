@file:JvmName("varargs_runme")

// varargs test

import varargs.*

fun main() {
    try {
        System.loadLibrary("varargs")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    if (varargs.test("Hello") != "Hello")
        throw RuntimeException("Failed")

    var f = Foo("BuonGiorno", 1)
    if (f.str != "BuonGiorno")
        throw RuntimeException("Failed")

    f = Foo("Greetings")
    if (f.str != "Greetings")
        throw RuntimeException("Failed")

    if (f.test("Hello") != "Hello")
        throw RuntimeException("Failed")

    if (Foo.statictest("Grussen", 1) != "Grussen")
        throw RuntimeException("Failed")
}
