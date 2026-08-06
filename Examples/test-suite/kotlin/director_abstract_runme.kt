@file:JvmName("director_abstract_runme")

import director_abstract.*

class director_abstract_MyFoo : Foo() {
    override fun ping(): String {
        return "director_abstract_MyFoo::ping()"
    }
}

class director_abstract_BadFoo : Foo()

fun main() {
    try {
        System.loadLibrary("director_abstract")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val a = director_abstract_MyFoo()

    if (a.ping() != "director_abstract_MyFoo::ping()") {
        throw RuntimeException("a.ping()")
    }

    if (a.pong() != "Foo::pong();director_abstract_MyFoo::ping()") {
        throw RuntimeException("a.pong()")
    }

    val b = director_abstract_BadFoo()
    try {
        b.ping()
        System.out.println("Test failed. An attempt to call a pure virtual method should throw an exception")
        kotlin.system.exitProcess(1)
    } catch (e: RuntimeException) {
    }
}
