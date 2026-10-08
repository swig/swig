@file:JvmName("template_nested_typemaps_runme")

import template_nested_typemaps.*

fun main() {
    try {
        System.loadLibrary("template_nested_typemaps")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val b = BreezeString()
    run {
        val v = 88
        val vTypemap = -99
        if (b.methodInt1(v) != v) throw RuntimeException("failed")
        if (b.methodInt2(v) != vTypemap) throw RuntimeException("failed")

        if (template_nested_typemaps.globalInt1(v) != v) throw RuntimeException("failed")
        if (template_nested_typemaps.globalInt2(v) != v) throw RuntimeException("failed")
        if (template_nested_typemaps.globalInt3(v) != vTypemap) throw RuntimeException("failed")
    }

    run {
        val v: Short = 88
        val vTypemap: Short = -77
        if (b.methodShort1(v) != v) throw RuntimeException("failed")
        if (b.methodShort2(v) != vTypemap) throw RuntimeException("failed")

        if (template_nested_typemaps.globalShort1(v) != v) throw RuntimeException("failed")
        if (template_nested_typemaps.globalShort2(v) != v) throw RuntimeException("failed")
        if (template_nested_typemaps.globalShort3(v) != vTypemap) throw RuntimeException("failed")
    }
}
