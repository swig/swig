@file:JvmName("director_ignore_runme")

import director_ignore.*

class DIgnoresDerived : DIgnores()

class DAbstractIgnoresDerived : DAbstractIgnores()

fun main() {
    try {
        System.loadLibrary("director_ignore")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Just check the classes can be instantiated and other methods work as expected
    val a = DIgnoresDerived()
    if (a.Triple(5) != 15)
        throw RuntimeException("Triple failed")
    val b = DAbstractIgnoresDerived()
    if (b.Quadruple(5) != 20)
        throw RuntimeException("Quadruple failed")
}
