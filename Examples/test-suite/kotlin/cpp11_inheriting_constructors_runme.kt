@file:JvmName("cpp11_inheriting_constructors_runme")

import cpp11_inheriting_constructors.*

fun main() {
    try {
        System.loadLibrary("cpp11_inheriting_constructors")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Constructor inheritance via using declaration
    val d = DerivedClass(10)
    if (d.retrieveValue() != 10)
        throw RuntimeException("retrieveValue() failed")

    // Member initialization at the site of the declaration
    val s = SomeClass()
    if (s.value != 5)
        throw RuntimeException("s.value failed")
}
