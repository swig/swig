@file:JvmName("director_basic_runme")

import director_basic.*

class KotlinMyFoo : Foo() {
    override fun ping(): String {
        return "KotlinMyFoo::ping()"
    }
}

fun main() {
    try {
        System.loadLibrary("director_basic")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val a = KotlinMyFoo()

    if (a.ping() != "KotlinMyFoo::ping()") {
        throw RuntimeException("a.ping(): " + a.ping())
    }

    if (a.pong() != "Foo::pong();KotlinMyFoo::ping()") {
        throw RuntimeException("a.pong(): " + a.pong())
    }

    val b = Foo()

    if (b.ping() != "Foo::ping()") {
        throw RuntimeException("b.ping(): " + b.ping())
    }

    if (b.pong() != "Foo::pong();Foo::ping()") {
        throw RuntimeException("b.pong(): " + b.pong())
    }

    val a1 = A1(1, false)
    a1.delete()
}
