@file:JvmName("template_class_reuse_name_runme")

import template_class_reuse_name.*

fun main() {
    try {
        System.loadLibrary("template_class_reuse_name")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    Bool1().tt()
    Bool1False().ff()

    Bool2().tt()
    Bool2False().ff()

    Bool3().tt()
    Bool3False().ff()

    Bool4().tt()
    Bool4False().ff()

    BoolForward1().tt()
    BoolForward1False().ff()

    BoolForward2().tt()
    BoolForward2False().ff()

    BoolForward3().tt()
    BoolForward3False().ff()

    BoolForward4().tt()
    BoolForward4False().ff()

    IntBool1().tt()
    IntBool1False().ff()

    IntBool2().tt()
    IntBool2False().ff()

    IntBool3().tt()
    IntBool3False().ff()

    IntBool4().tt()
    IntBool4False().ff()

    Duplicate2_0().n()
    Duplicate3().n()
}
