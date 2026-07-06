@file:JvmName("kotlin_director_assumeoverride_runme")

import kotlin_director_assumeoverride.*

// MyOverrideMe doesn't actually override funk(), but because assumeoverride
// was set to true, the C++ side will believe it was overridden.
class kotlin_director_assumeoverride_MyOverrideMe : OverrideMe()

fun main() {
    try {
        System.loadLibrary("kotlin_director_assumeoverride")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val overrideMe: OverrideMe = kotlin_director_assumeoverride_MyOverrideMe()

    if (!kotlin_director_assumeoverride.isFuncOverridden(overrideMe)) {
        throw RuntimeException("isFuncOverridden()")
    }
}
