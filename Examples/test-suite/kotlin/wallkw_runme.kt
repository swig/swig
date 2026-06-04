@file:JvmName("wallkw_runme")

import wallkw.*

fun main() {
    try {
        System.loadLibrary("wallkw")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    if (wallkw.c_clone() != "clone")
        throw RuntimeException("clone_c keyword fail")
    if (wallkw._delegate() != "delegate")
        throw RuntimeException("delegate keyword fail")
    if (wallkw._pass() != "pass")
        throw RuntimeException("pass keyword fail")
    if (wallkw._alias() != "alias")
        throw RuntimeException("alias keyword fail")
    if (wallkw.C_rescue() != "rescue")
        throw RuntimeException("rescue keyword fail")
}
