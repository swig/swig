@file:JvmName("namespace_chase_runme")

import namespace_chase.*

fun main() {
    try {
        System.loadLibrary("namespace_chase")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val s1a = Struct1A()
    val s1b = Struct1B()
    val s1c = Struct1C()

    namespace_chase.sss3a(s1a, s1b, s1c)
    namespace_chase.sss3b(s1a, s1b, s1c)
    // needs fixing
    // namespace_chase.sss3c(s1a, s1b, s1c)
}
