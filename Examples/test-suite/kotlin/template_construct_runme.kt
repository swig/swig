@file:JvmName("template_construct_runme")

import template_construct.*

fun main() {
    try {
        System.loadLibrary("template_construct")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val fi = Foo_int(0)
    fi.delete()
    var fs = Foo_short()
    fs.delete()
    fs = Foo_short()
    fs.delete()
}
