@file:JvmName("multiple_inheritance_runme")

import multiple_inheritance.*

fun main() {
    try {
        System.loadLibrary("multiple_inheritance")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val fooBar = FooBar()
    fooBar.foo()

    val ignoreDerived1 = IgnoreDerived1()
    ignoreDerived1.bar()

    val ignoreDerived2 = IgnoreDerived2()
    ignoreDerived2.bar()

    val ignoreDerived3 = IgnoreDerived3()
    ignoreDerived3.bar()

    val ignoreDerived4 = IgnoreDerived4()
    ignoreDerived4.bar()
}
