@file:JvmName("template_default_cache_runme")

import template_default_cache.*

fun main() {
    try {
        System.loadLibrary("template_default_cache")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val ap = template_default_cache.get_mp_a()
    val bp = template_default_cache.get_mp_b()
}
