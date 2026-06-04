@file:JvmName("director_unroll_runme")

import director_unroll.*

class director_unroll_MyFoo : Foo() {
    override fun ping(): String {
        return "director_unroll_MyFoo::ping()"
    }
}

fun main() {
    try {
        System.loadLibrary("director_unroll")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val a = director_unroll_MyFoo()

    val b = Bar()

    b.set(a)
    val c = b.get()

    if (c!!.ping() != "director_unroll_MyFoo::ping()")
        throw RuntimeException("c.ping()")
}
