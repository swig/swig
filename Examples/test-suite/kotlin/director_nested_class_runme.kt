@file:JvmName("director_nested_class_runme")

import director_nested_class.*

class director_nested_class_Derived : DirectorOuter.DirectorInner() {
    override fun vmethod(input: Int): Int {
        return input * 10
    }
}

class director_nested_class_DerivedInnerInner : DirectorOuter.DirectorInner.DirectorInnerInner() {
    override fun innervmethod(input: Int): Int {
        return input * 1000
    }
}

fun main() {
    try {
        System.loadLibrary("director_nested_class")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val d = director_nested_class_Derived()

    if (DirectorOuter.callMethod(d, 999) != 9990) {
        throw RuntimeException("callMethod(999) failed")
    }

    val dinner = director_nested_class_DerivedInnerInner()

    if (DirectorOuter.callInnerInnerMethod(dinner, 999) != 999000) {
        throw RuntimeException("callMethod(999) failed")
    }
}
