@file:JvmName("cpp17_director_string_view_runme")

import cpp17_director_string_view.*

class cpp17_director_string_view_B(first: String) : A(first) {
    override fun get_first(): String {
        return "cpp17_director_string_view_B.get_first"
    }

    override fun get(n: Int): String {
        return "cpp17_director_string_view_B.get: " + super.get(n)
    }
}

class cpp17_director_string_view_A(first: String) : A(first) {
    override fun get(n: Int): String {
        return n.toString()
    }
}

fun main() {
    try {
        System.loadLibrary("cpp17_director_string_view")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    var s: String

    val c = cpp17_director_string_view_A("hi")
    for (i in 0 until 3) {
        s = c.call_get(i)
        if (s != i.toString()) throw RuntimeException("cpp17_director_string_view_A.get(" + i + ") failed. Got:" + s)
    }

    val b = cpp17_director_string_view_B("hello")

    s = b.get_first()
    if (s != "cpp17_director_string_view_B.get_first") throw RuntimeException("get_first() failed")

    s = b.call_get_first()
    if (s != "cpp17_director_string_view_B.get_first") throw RuntimeException("call_get_first() failed")

    s = b.call_get(0)
    if (s != "cpp17_director_string_view_B.get: hello") throw RuntimeException("get(0) failed")
}
