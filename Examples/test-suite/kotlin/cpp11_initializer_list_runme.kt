@file:JvmName("cpp11_initializer_list_runme")

import cpp11_initializer_list.*

fun main() {
    try {
        System.loadLibrary("cpp11_initializer_list")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val c = C(SWIGTYPE_p_std__initializer_listT_char_const_p_t(0, false))
    val joined = c.get_joined_string()
    if (joined != "AbFab")
        throw RuntimeException("Wrong joined string " + joined)
}
