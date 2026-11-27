@file:JvmName("template_template_template_parameters_runme")

import template_template_template_parameters.*

fun main() {
    try {
        System.loadLibrary("template_template_template_parameters")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    var custom_attrs: CustomAttrs? // = CustomAttrs() - initializer is redundant
    val ac = AC()
    val bac = BAC()
    val cbac = CBAC()
    val dbac = DBAC()

    @Suppress("UNUSED_VALUE")
    custom_attrs = ac.attributes
    @Suppress("UNUSED_VALUE")
    custom_attrs = bac.attributes
    @Suppress("UNUSED_VALUE")
    custom_attrs = cbac.attributes
    custom_attrs = dbac.attributes

    bac.BMethod(custom_attrs, ac)
    cbac.BMethod(custom_attrs, ac)
    dbac.BMethod(custom_attrs, ac)

    cbac.CMethod(custom_attrs, bac)
    dbac.DMethod(custom_attrs, bac)
}
