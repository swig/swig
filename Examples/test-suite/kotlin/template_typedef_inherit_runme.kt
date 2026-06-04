@file:JvmName("template_typedef_inherit_runme")

import template_typedef_inherit.*

fun main() {
    try {
        System.loadLibrary("template_typedef_inherit")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val d = DescriptionImplementationTypedCollectionInterfaceObject()
    d.add("a string")

    val s = StringPersistentCollection()
    s.add("a string")
}
