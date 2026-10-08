@file:JvmName("director_string_runme")

import director_string.*

class director_string_B(first: String) : A(first) {
    override fun get_first(): String {
        return "director_string_B.get_first"
    }

    override fun get(n: Int): String {
        return "director_string_B.get: " + super.get(n)
    }
}

class director_string_A(first: String) : A(first) {
    override fun get(n: Int): String {
        return Integer.valueOf(n).toString()
    }
}

fun main() {
    try {
        System.loadLibrary("director_string")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    var s: String

    val c = director_string_A("hi")
    for (i in 0..2) {
        s = c.call_get(i)
        if (s != Integer.valueOf(i).toString()) throw RuntimeException("director_string_A.get(" + i + ") failed. Got:" + s)
    }

    val b = director_string_B("hello")

    s = b.get_first()
    if (s != "director_string_B.get_first") throw RuntimeException("get_first() failed")

    s = b.call_get_first()
    if (s != "director_string_B.get_first") throw RuntimeException("call_get_first() failed")

    s = b.call_get(0)
    if (s != "director_string_B.get: hello") throw RuntimeException("get(0) failed")
}
