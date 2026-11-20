@file:JvmName("nested_workaround_runme")

import nested_workaround.*

fun main() {
    try {
        System.loadLibrary("nested_workaround")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    run {
        val inner = Inner(5)
        val outer = Outer()
        val newInner = outer.doubleInnerValue(inner)
        if (newInner.getValue() != 10)
            throw RuntimeException("inner failed")
    }

    run {
        val outer = Outer()
        val inner = outer.createInner(3)
        val newInner = outer.doubleInnerValue(inner)
        if (outer.getInnerValue(newInner) != 6)
            throw RuntimeException("inner failed")
    }
}
