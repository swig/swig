@file:JvmName("cpp11_default_delete_runme")

import cpp11_default_delete.*

fun main() {
    try {
        System.loadLibrary("cpp11_default_delete")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    var st = sometype(22.2)
    sometype.take(st)
    st = sometype.make(33.3)

    var st2 = sometype2(22.2)
    sometype2.take(st2)
    st2 = sometype2.make(33.3)

    var st3 = sometype3.make(22)
    sometype3.take(st3)
    st3 = sometype3.make(33)
}
