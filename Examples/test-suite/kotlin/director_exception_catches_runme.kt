@file:JvmName("director_exception_catches_runme")

import director_exception_catches.*

class director_exception_catches_MyClass : BaseClass() {
    override fun description(): String {
        throw NullPointerException("Testing exception thrown in BaseClass.description")
    }
}

fun main() {
    try {
        System.loadLibrary("director_exception_catches")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val b: BaseClass = director_exception_catches_MyClass()

    try {
        val s = BaseClass.call_description(b)
        throw RuntimeException("Failed to catch exception")
    } catch (e: NullPointerException) {
        if (e.message == null || !e.message!!.startsWith("Testing exception thrown in BaseClass.description"))
            throw RuntimeException("Unexpected exception message: " + e.message)
    }
}
