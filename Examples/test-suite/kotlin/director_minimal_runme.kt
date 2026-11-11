@file:JvmName("director_minimal_runme")

import director_minimal.*

class MyMinimal : Minimal() {
    override fun run(): Boolean {
        return true
    }
}

fun main() {
    try {
        System.loadLibrary("director_minimal")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val c = MyMinimal()
    if (!c.get())
        throw RuntimeException("Should return true")
}
