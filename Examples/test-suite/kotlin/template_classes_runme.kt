@file:JvmName("template_classes_runme")

import template_classes.*

fun main() {
    try {
        System.loadLibrary("template_classes")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val rectint = RectangleInt()
    val pi = rectint.getPoint()
    val x = pi.getX()
}
