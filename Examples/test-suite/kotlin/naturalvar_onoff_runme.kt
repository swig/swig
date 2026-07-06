@file:JvmName("naturalvar_onoff_runme")

import naturalvar_onoff.*

// Test naturalvar feature override.
// "On" members use the const-reference typemap (non-null Kotlin property), which
// rejects null at runtime (native code throws NullPointerException).
// "Off" members use the pointer typemap (nullable Kotlin property), which accepts null.

@Suppress("UNCHECKED_CAST", "CAST_NEVER_SUCCEEDS")
private fun <T> forceNull(): T = (null as Any?) as T

fun main() {
    try {
        System.loadLibrary("naturalvar_onoff")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    var fail: Boolean
    val vars = Vars()

    fail = true
    try {
        vars.member1On = forceNull()
    } catch (e: NullPointerException) {
        fail = false
    }
    if (fail) throw RuntimeException("Failed")

    vars.member2Off = null

    vars.member3Off = null

    fail = true
    try {
        vars.member3On = forceNull()
    } catch (e: NullPointerException) {
        fail = false
    }
    if (fail) throw RuntimeException("Failed")

    vars.member4Off = null

    fail = true
    try {
        vars.member4On = forceNull()
    } catch (e: NullPointerException) {
        fail = false
    }
    if (fail) throw RuntimeException("Failed")
}
