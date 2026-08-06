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
    @Suppress("ASSIGNED_BUT_NEVER_ACCESSED_VARIABLE")
    var value: Short = 0
    @Suppress("UNUSED_VALUE")
    value = ys.create1()
    @Suppress("UNUSED_VALUE")
    value = ys.create2()
    @Suppress("UNUSED_VALUE")
    value = ys.create3()
    @Suppress("UNUSED_VALUE")
    value = ys.create4()
    @Suppress("UNUSED_VALUE")
    value = ys.create5()
    @Suppress("UNUSED_VALUE")
    value = ys.create6()
    @Suppress("UNUSED_VALUE")
    value = ys.create7()

    @Suppress("UNUSED_VALUE")
    value = ys.create13()

    @Suppress("UNUSED_VALUE")
    value = ys.create15()
    @Suppress("UNUSED_VALUE")
    value = ys.create16()
    @Suppress("UNUSED_VALUE")
    value = ys.create17()
}
