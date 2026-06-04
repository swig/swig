@file:JvmName("template_default_class_parms_runme")

import template_default_class_parms.*

fun main() {
    try {
        System.loadLibrary("template_default_class_parms")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    run {
        val bar = DefaultBar(20.0, SomeType(), 10)
        var d = bar.CType
        bar.CType = d
        val s = bar.DType
        bar.DType = s
        val i = bar.EType
        bar.EType = i
        d = bar.method(d, s!!, i)
    }
    run {
        val foo = DefaultFoo(SomeType())
        var s = foo.TType
        s = foo.method(s!!)
    }
    run {
        val bar = BarAnotherTypeBool(AnotherType(), true, 10)
        var a = bar.CType
        bar.CType = a
        val b = bar.DType
        bar.DType = b
        val i = bar.EType
        bar.EType = i
        a = bar.method(a!!, b, i)
    }
    run {
        val foo = FooAnotherType(AnotherType())
        var a = foo.TType
        foo.TType = a
        a = foo.method(a!!)
    }
    // MapDefaults (Tpetra::Map<>) is only instantiated for SWIGJAVA, not Kotlin.
}
