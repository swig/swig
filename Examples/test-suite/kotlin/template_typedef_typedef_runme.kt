@file:JvmName("template_typedef_typedef_runme")

import template_typedef_typedef.*

fun main() {
    try {
        System.loadLibrary("template_typedef_typedef")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val ob1 = Object1Base()
    ob1.getBlabla1(Object1Base())
    val ob2 = Object2Base()
    ob2.getBlabla2(Object2Base())

    val factory = Factory()
    factory.getBlabla3(Object1Base())
    factory.getBlabla4(Object2Base())
}
