@file:JvmName("director_property_runme")

import director_property.*

class director_property_MyFoo : Foo() {
    override fun setA(a: String) {
        super.setA(a + " set from MyFoo")
    }

    override fun setAByRef(a: String) {
        super.setA(a + " setAByRef from MyFoo")
    }
}

fun main() {
    try {
        System.loadLibrary("director_property")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    run {
        val a: Foo = director_property_MyFoo()
        if (a.getA() != "") {
            throw RuntimeException("Test failed")
        }
        a.setA("Hello")
        if (a.getA() != "Hello set from MyFoo") {
            throw RuntimeException("Test failed")
        }
        a.setAByRef("Hello")
        if (a.getA() != "Hello setAByRef from MyFoo") {
            throw RuntimeException("Test failed")
        }
        a.delete()
    }

    run {
        val a_original: Foo = director_property_MyFoo()
        val a: Foo = Foo.get_self(a_original)!!
        if (a.getA() != "") {
            throw RuntimeException("Test failed")
        }
        a.setA("Hello")
        if (a.getA() != "Hello set from MyFoo") {
            throw RuntimeException("Test failed")
        }
        a.setAByRef("Hello")
        if (a.getA() != "Hello setAByRef from MyFoo") {
            throw RuntimeException("Test failed")
        }
        a.delete()
    }
}
