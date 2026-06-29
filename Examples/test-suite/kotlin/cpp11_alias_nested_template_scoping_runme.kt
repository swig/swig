@file:JvmName("cpp11_alias_nested_template_scoping_runme")

import cpp11_alias_nested_template_scoping.*

fun main() {
    try {
        System.loadLibrary("cpp11_alias_nested_template_scoping")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val ys = Yshort()
    var value: Short = 0
    value = ys.create1()
    value = ys.create2()
    value = ys.create3()
    value = ys.create4()
    value = ys.create5()
    value = ys.create6()
    value = ys.create7()

    value = ys.create13()

    value = ys.create15()
    value = ys.create16()
    value = ys.create17()
}
