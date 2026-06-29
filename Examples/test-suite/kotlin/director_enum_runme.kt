@file:JvmName("director_enum_runme")

import director_enum.*

class director_enum_MyFoo : Foo() {
    override fun say_hi(h: Hallo): Hallo {
        return Hallo.yo
    }
    override fun say_hi_ref(h: Hallo): Hallo {
        return Hallo.hello
    }
    override fun say_bye(b: Foo.Bye): Foo.Bye {
        return Foo.Bye.aufwiedersehen
    }
}

fun main() {
    try {
        System.loadLibrary("director_enum")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val a = director_enum_MyFoo()

    if (a.ping(Hallo.awright) != Hallo.yo) {
        throw RuntimeException("a.ping()")
    }
    if (a.ping_ref(Hallo.awright) != Hallo.hello) {
        throw RuntimeException("a.ping_ref()")
    }
    if (a.ping_member_enum(Foo.Bye.adios) != Foo.Bye.aufwiedersehen) {
        throw RuntimeException("a.ping_member_enum()")
    }

    val b = Foo()

    if (b.ping(Hallo.awright) != Hallo.awright) {
        throw RuntimeException("b.ping()")
    }
    if (b.ping_ref(Hallo.awright) != Hallo.awright) {
        throw RuntimeException("b.ping_ref()")
    }
    if (b.ping_member_enum(Foo.Bye.adios) != Foo.Bye.adios) {
        throw RuntimeException("b.ping_member_enum()")
    }
}
