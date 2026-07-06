@file:JvmName("dynamic_cast_runme")

import dynamic_cast.*

fun main() {
    try {
        System.loadLibrary("dynamic_cast")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val f = Foo()
    val b = Bar()

    val x = f.blah()
    val y = b.blah()

    // Note it is possible to downcast y with a Kotlin cast.
    val a = dynamic_cast.do_test(y as Bar?)
    if (a != "Bar::test") {
        throw RuntimeException("Failed!")
    }
}
