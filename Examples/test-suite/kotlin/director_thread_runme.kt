@file:JvmName("director_thread_runme")

import director_thread.*

class director_thread_Derived : Foo() {
    override fun do_foo() {
        // Not all operating systems can name threads, so only test on those that can
        if (Foo.namedThread()) {
            val threadName = Thread.currentThread().name
            if (threadName != "MyThreadName")
                throw RuntimeException("Unexpected thread name: " + threadName)
        }
        _val = _val - 1
    }
}

fun main() {
    try {
        System.loadLibrary("director_thread")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // This test used to hang the process.
    val d = director_thread_Derived()
    d.run()

    if (d._val >= 0) {
        throw RuntimeException("Failed. Val: " + d._val)
    }
    d.stop()
}
