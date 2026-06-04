@file:JvmName("kwargs_feature_runme")

import kwargs_feature.*

fun main() {
    try {
        System.loadLibrary("kwargs_feature")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Check normal overloading still works (no compactdefaultargs) if the kwargs feature is used,
    // as the kwargs feature is not supported
    val f = Foo(99)
    if (f.foo() != 1)
        throw RuntimeException("It went wrong")
    if (Foo.statfoo(2) != 2)
        throw RuntimeException("It went wrong")
}
