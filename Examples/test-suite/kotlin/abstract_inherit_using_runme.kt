@file:JvmName("abstract_inherit_using_runme")

import abstract_inherit_using.*

fun main() {
    try {
        System.loadLibrary("abstract_inherit_using")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val cd1 = ConcreteDerived1()
    cd1.f(1234)
    cd1.f("one")
    val cd2 = ConcreteDerived2()
    cd2.f(1234)
    cd2.f("one")
}
