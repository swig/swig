@file:JvmName("director_default_runme")

import director_default.*

class director_default_MyFoo : Foo {
    constructor() : super()
    constructor(i: Int) : super(i)
    override fun Msg(msg: String): String {
        return "director_default_MyFoo-" + msg
    }
}

fun main() {
    try {
        System.loadLibrary("director_default")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    run {
        var a = director_default_MyFoo()
        a = director_default_MyFoo(10)
        a.delete()
    }

    run {
        val a = director_default_MyFoo()
        if (a.GetMsg() != "director_default_MyFoo-default") {
            throw RuntimeException("Test 1 failed")
        }
        if (a.GetMsg("boo") != "director_default_MyFoo-boo") {
            throw RuntimeException("Test 2 failed")
        }
        a.delete()
    }

    run {
        val b = Foo()
        if (b.GetMsg() != "Foo-default") {
            throw RuntimeException("Test 1 failed")
        }
        if (b.GetMsg("boo") != "Foo-boo") {
            throw RuntimeException("Test 2 failed")
        }
        b.delete()
    }
}
